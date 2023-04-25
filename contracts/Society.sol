// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";

contract Society is ERC721 {
    uint256 public immutable i_deplotTimestamp;
    address public immutable i_registrar;
    // available addresses
    bytes32[] public s_plotAddresses;
    address[] public s_potentialOwners;
    mapping(bytes32 => address) public plotAddressToPotentialOwner;
    // token counter
    uint256 private s_tokenCounter;
    mapping(bytes32 => uint256) public plotAddressToTokenId;
    mapping(bytes32 => address) public plotAddToOwner;

    constructor(
        string memory name,
        string memory symbol,
        bytes32[] memory plotAddresses,
        address[] memory potentialOwners
    ) ERC721(name, symbol) {
        require(plotAddresses.length == potentialOwners.length, "Incorrect data provided");

        i_deplotTimestamp = block.timestamp;
        i_registrar = msg.sender;
        s_tokenCounter = 0;
        s_plotAddresses = plotAddresses;
        s_potentialOwners = potentialOwners;
        for (uint i = 0; i < plotAddresses.length; i++) {
            plotAddressToPotentialOwner[plotAddresses[i]] = potentialOwners[i];
        }
    }

    function approve(address to, uint256 tokenId) public override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        _approve(to, tokenId);
    }

    function mintNFT(
        address caller,
        bytes32 plotAdd
    ) public onlyRegistrar onlyPotentialPlotOwner(caller, plotAdd) returns (uint256) {
        _safeMint(caller, s_tokenCounter);
        approve(i_registrar, s_tokenCounter);
        plotAddressToTokenId[plotAdd] = s_tokenCounter;
        plotAddToOwner[plotAdd] = caller;
        s_tokenCounter = s_tokenCounter + 1;
        return s_tokenCounter - 1;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getTokenIdOfPlot(bytes32 plotAdd) public view returns (uint256) {
        return plotAddressToTokenId[plotAdd];
    }

    function closeSaleOffer(address owner, address buyer, uint256 tokenId) public onlyRegistrar {
        safeTransferFrom(owner, buyer, tokenId);
    }

    function isPlotOwner(address caller, bytes32 plotAdd) public view onlyPlotOwner(caller, plotAdd) {}

    modifier onlyRegistrar() {
        require(msg.sender == i_registrar);
        _;
    }

    modifier onlyPlotOwner(address caller, bytes32 plotAdd) {
        require(plotAddToOwner[plotAdd] == caller, "Not Owner of Plot.");
        _;
    }

    modifier onlyPotentialPlotOwner(address caller, bytes32 plotAdd) {
        require(
            caller == plotAddressToPotentialOwner[plotAdd] || block.timestamp > (i_deplotTimestamp + 6 * 30.44 days),
            "Not Potential Owner"
        );
        _;
    }
}
