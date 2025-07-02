// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

contract SmartContractRegistryV2 {
    struct RegisteredContract {
        string name;
        string description;
        address contractAddress;
        uint256 registrationTime;
    }

    mapping(address => RegisteredContract) public contracts;
    address[] public registeredAddresses;

    event ContractRegistered(address contractAddress, string name, string description);
    event ContractUpdated(address contractAddress, string name, string description);

    function registerContract(address _contractAddress, string memory _name, string memory _description) public {
        require(contracts[_contractAddress].contractAddress == address(0), "Contract already registered");
        contracts[_contractAddress] = RegisteredContract(_name, _description, _contractAddress, block.timestamp);
        registeredAddresses.push(_contractAddress);
        emit ContractRegistered(_contractAddress, _name, _description);
    }

    function updateContract(address _contractAddress, string memory _name, string memory _description) public {
        require(contracts[_contractAddress].contractAddress != address(0), "Contract not registered");
        contracts[_contractAddress].name = _name;
        contracts[_contractAddress].description = _description;
        emit ContractUpdated(_contractAddress, _name, _description);
    }

    function getContract(address _contractAddress) public view returns (string memory, string memory, uint256) {
        require(contracts[_contractAddress].contractAddress != address(0), "Contract not registered");
        RegisteredContract memory contractInfo = contracts[_contractAddress];
        return (contractInfo.name, contractInfo.description, contractInfo.registrationTime);
    }

    function getAllContracts() public view returns (address[] memory, string[] memory, string[] memory, uint256[] memory) {
        address[] memory addresses = new address[](registeredAddresses.length);
        string[] memory names = new string[](registeredAddresses.length);
        string[] memory descriptions = new string[](registeredAddresses.length);
        uint256[] memory registrationTimes = new uint256[](registeredAddresses.length);

        for (uint256 i = 0; i < registeredAddresses.length; i++) {
            addresses[i] = registeredAddresses[i];
            names[i] = contracts[registeredAddresses[i]].name;
            descriptions[i] = contracts[registeredAddresses[i]].description;
            registrationTimes[i] = contracts[registeredAddresses[i]].registrationTime;
        }

        return (addresses, names, descriptions, registrationTimes);
    }
}