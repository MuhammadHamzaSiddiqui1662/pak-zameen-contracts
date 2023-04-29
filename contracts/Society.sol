// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error ERC721_ApprovalToCurrentOwner();
error Society_OnlyRegistrarCanCall();
error Society_IncorrectDataProvided();
error Society_NotOwnerOfPlot();

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
    mapping(bytes32 => address) public plotAddressToOwner;
    mapping(address => bytes32[]) public ownerToPotentialPlots;
    mapping(address => bytes32[]) public ownerToOwnedPlots;

    constructor(
        string memory name,
        string memory symbol,
        bytes32[] memory plotAddresses,
        address[] memory potentialOwners
    ) ERC721(name, symbol) {
        if (plotAddresses.length != potentialOwners.length) revert Society_IncorrectDataProvided();
        i_deplotTimestamp = block.timestamp;
        i_registrar = msg.sender;
        s_tokenCounter = 1;
        s_plotAddresses = plotAddresses;
        s_potentialOwners = potentialOwners;
        for (uint i = 0; i < plotAddresses.length; i++) {
            plotAddressToPotentialOwner[plotAddresses[i]] = potentialOwners[i];
            ownerToPotentialPlots[potentialOwners[i]].push(plotAddresses[i]);
        }
    }

    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        if (to == owner) revert ERC721_ApprovalToCurrentOwner();

        _approve(to, tokenId);
    }

    function mintNFT(
        address caller,
        bytes32 plotAddress
    ) public onlyRegistrar onlyPotentialPlotOwner(caller, plotAddress) returns (uint256) {
        _safeMint(caller, s_tokenCounter);
        approve(i_registrar, s_tokenCounter);
        plotAddressToTokenId[plotAddress] = s_tokenCounter;
        bytes32[] memory potentialPlots = ownerToPotentialPlots[caller];
        for (uint256 i = 0; i < potentialPlots.length; i = i + 1) {
            if (plotAddress == potentialPlots[i]) {
                if (potentialPlots.length > 1) {
                    potentialPlots[i] = potentialPlots[potentialPlots.length - 1];
                    ownerToPotentialPlots[caller] = potentialPlots;
                }
                ownerToPotentialPlots[caller].pop();
                ownerToOwnedPlots[caller].push(plotAddress);
                plotAddressToOwner[plotAddress] = caller;
            }
        }
        s_tokenCounter = s_tokenCounter + 1;
        return s_tokenCounter - 1;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getAllPotentialPlots(address owner) public view returns (bytes32[] memory) {
        return ownerToPotentialPlots[owner];
    }

    function getAllOwnedPlots(address owner) public view returns (bytes32[] memory) {
        return ownerToOwnedPlots[owner];
    }

    function closeSaleOffer(address owner, address buyer, bytes32 plotAddress) public onlyRegistrar {
        uint256 tokenId = plotAddressToTokenId[plotAddress];
        safeTransferFrom(owner, buyer, tokenId);
        bytes32[] memory ownedPlots = ownerToOwnedPlots[owner];
        for (uint256 i = 0; i < ownedPlots.length; i = i + 1) {
            if (plotAddress == ownedPlots[i]) {
                if (ownedPlots.length > 1) {
                    ownedPlots[i] = ownedPlots[ownedPlots.length - 1];
                    ownerToOwnedPlots[owner] = ownedPlots;
                }
                ownerToOwnedPlots[owner].pop();
                ownerToOwnedPlots[buyer].push(plotAddress);
                plotAddressToOwner[plotAddress] = buyer;
            }
        }
    }

    function isPlotOwner(address caller, bytes32 plotAddress) public view onlyPlotOwner(caller, plotAddress) {}

    modifier onlyRegistrar() {
        if (msg.sender != i_registrar) revert Society_OnlyRegistrarCanCall();
        _;
    }

    modifier onlyPlotOwner(address caller, bytes32 plotAddress) {
        if (plotAddressToOwner[plotAddress] != caller) revert Society_NotOwnerOfPlot();
        _;
    }

    modifier onlyPotentialPlotOwner(address caller, bytes32 plotAddress) {
        require(
            caller == plotAddressToPotentialOwner[plotAddress] ||
                block.timestamp > (i_deplotTimestamp + 6 * 30.44 days),
            "Not Potential Owner"
        );
        _;
    }
}
