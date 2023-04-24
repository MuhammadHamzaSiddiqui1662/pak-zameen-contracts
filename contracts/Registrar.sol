// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./Society.sol";
import "hardhat/console.sol";

contract Registrar {
    // sell id
    uint256 public s_saleId;
    struct Sale {
        address owner;
        bytes32 plotAdd;
        uint256 tokenId;
        uint256 price;
        bool isOpen;
    }
    mapping(uint256 => Sale) saleIdToSaleOffer;

    // societies
    mapping(string => address) public societyToAddress;

    // events
    event NewSocietyCreated(string societyName, string symbol, address societyAddress);
    event SaleOffer(address indexed owner, bytes32 indexed plotAdd, uint256 indexed price);

    constructor() {
        s_saleId = 0;
    }

    function createSociety(
        string memory name,
        string memory symbol,
        bytes32[] memory plotAddresses,
        address[] memory potentialOwners
    ) public returns (address societyAddress) {
        address societyContractAddress = address(new Society(name, symbol, plotAddresses, potentialOwners));
        societyToAddress[name] = societyContractAddress;
        emit NewSocietyCreated(name, symbol, societyContractAddress);
        return societyContractAddress;
    }

    function claimAsset(address societyAddress, bytes32 plotAdd) public returns (uint256 tokenId) {
        Society society = Society(societyAddress);
        return society.mintNFT(msg.sender, plotAdd);
    }

    function initiateSale(address societyAddress, bytes32 plotAdd, uint256 price) public returns (uint256 saleId) {
        Society society = Society(societyAddress);
        society.isPlotOwner(msg.sender, plotAdd);
        saleIdToSaleOffer[s_saleId] = Sale(msg.sender, plotAdd, society.getTokenIdOfPlot(plotAdd), price, true);
        emit SaleOffer(msg.sender, plotAdd, price);
        s_saleId = s_saleId + 1;
        return s_saleId - 1;
    }

    function confirmSale(address societyAddress, uint256 saleId) public payable {
        require(msg.value >= saleIdToSaleOffer[saleId].price);
        Society society = Society(societyAddress);
        society.closeSaleOffer(saleIdToSaleOffer[saleId].owner, msg.sender, saleIdToSaleOffer[saleId].tokenId);
        delete saleIdToSaleOffer[saleId];
    }

    function selfTransfer(address societyAddress, uint256 saleId, address to) public {
        Society society = Society(societyAddress);
        society.isPlotOwner(msg.sender, saleIdToSaleOffer[saleId].plotAdd);
        society.closeSaleOffer(msg.sender, to, saleIdToSaleOffer[saleId].tokenId);
        delete saleIdToSaleOffer[saleId];
    }
}
