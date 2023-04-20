// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./Society.sol";

contract Registrar {
    // sell id
    uint256 public s_sellId;
    struct Sell {
        bytes32 plotAdd;
        uint256 price;
        address owner;
        address buyer;
    }
    mapping(uint256 => Sell) sellIdToSell;

    // societies
    mapping(string => address) public societyToAddress;

    // events
    event NewSocietyCreated(string societyName, string symbol, address societyAddress);

    constructor() {
        s_sellId = 0;
    }

    function createSociety(
        string memory name,
        string memory symbol,
        bytes32[] memory plotAddresses,
        address[] memory potentialOwners
    ) public returns (address) {
        address societyContractAddress = address(new Society(name, symbol, plotAddresses, potentialOwners));
        societyToAddress[name] = societyContractAddress;
        emit NewSocietyCreated(name, symbol, societyContractAddress);
        return societyContractAddress;
    }
}
