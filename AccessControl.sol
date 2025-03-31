// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract AccessControl {
    address public owner;
    mapping(address => bool) public hasAccess;

    event AccessGranted(address indexed user);
    event AccessRevoked(address indexed user);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function grantAccess(address user) public onlyOwner {
        require(!hasAccess[user], "User already has access");
        hasAccess[user] = true;
        emit AccessGranted(user);
    }

    function revokeAccess(address user) public onlyOwner {
        require(hasAccess[user], "User does not have access");
        hasAccess[user] = false;
        emit AccessRevoked(user);
    }
}