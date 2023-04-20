// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Society is ERC721 {
    uint256 public immutable i_deplotTimestamp;
    address public immutable i_registrar;
    // available addresses
    bytes32[] public s_plotAddresses;
    address[] public s_potentialOwners;
    mapping(bytes32 => address) plotAddressToPotentialOwner;
    // token counter
    uint256 private s_tokenCounter;
    mapping(uint256 => bytes32) tokenCounterToTicker;
    mapping(bytes32 => address) plotAddToOwner;
    // sell id
    uint256 s_sellId;
    struct Sale {
        address owner;
        bytes32 plotAdd;
        uint256 price;
        bool isOpen;
    }
    mapping(uint256 => Sale) saleIdToSaleOffer;

    event SaleOffer(address indexed owner, bytes32 indexed plotAdd, uint256 indexed price, bool isOpen);

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
        s_sellId = 0;
        s_plotAddresses = plotAddresses;
        s_potentialOwners = potentialOwners;
        for (uint i = 0; i < plotAddresses.length; i++) {
            plotAddressToPotentialOwner[plotAddresses[i]] = potentialOwners[i];
        }
    }

    function mintNFT(bytes32 plotAdd) public onlyPotentialOwner(plotAdd) returns (uint256) {
        _safeMint(msg.sender, s_tokenCounter);
        approve(i_registrar, s_tokenCounter);
        tokenCounterToTicker[s_tokenCounter] = plotAdd;
        plotAddToOwner[plotAdd] = msg.sender;
        s_tokenCounter = s_tokenCounter + 1;
        return s_tokenCounter;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function generateSellOffer(bytes32 plotAdd, uint256 price) public returns (uint256) {
        require(plotAddToOwner[plotAdd] == msg.sender, "Not Owner of Plot.");
        saleIdToSaleOffer[s_sellId] = Sale(msg.sender, plotAdd, price, true);
        s_sellId = s_sellId + 1;
        return s_sellId - 1;
    }

    modifier onlyPotentialOwner(bytes32 plotAdd) {
        require(
            msg.sender == plotAddressToPotentialOwner[plotAdd] ||
                block.timestamp > (i_deplotTimestamp + 6 * 30.44 days),
            "Not Potential Owner"
        );
        _;
    }
}
