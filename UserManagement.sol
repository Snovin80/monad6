// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title UserManagement
 * @dev A contract to manage users and their balances
 */
contract UserManagement {
    address public owner;
    mapping(address => uint256) public userBalances;
    address[] public userList;

    /**
     * @dev Sets the contract deployer as the owner
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Modifier to check if caller is the owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    /**
     * @dev Add a new user with an initial balance
     * @param user The address of the user
     * @param balance The initial balance for the user
     */
    function addUser(address user, uint256 balance) public onlyOwner {
        require(user != address(0), "Invalid address");
        require(userBalances[user] == 0, "User already exists");
        userBalances[user] = balance;
        userList.push(user);
    }

    /**
     * @dev Remove a user
     * @param user The address of the user to remove
     */
    function removeUser(address user) public onlyOwner {
        require(user != address(0), "Invalid address");
        require(userBalances[user] > 0, "User does not exist");

        // Remove the user from the userList
        for (uint256 i = 0; i < userList.length; i++) {
            if (userList[i] == user) {
                userList[i] = userList[userList.length - 1];
                userList.pop();
                break;
            }
        }

        // Delete the user's balance
        delete userBalances[user];
    }

    /**
     * @dev Update the balance of a user
     * @param user The address of the user
     * @param balance The new balance for the user
     */
    function updateUserBalance(address user, uint256 balance) public onlyOwner {
        require(user != address(0), "Invalid address");
        require(userBalances[user] > 0, "User does not exist");
        userBalances[user] = balance;
    }

    /**
     * @dev Retrieve the balance of a user
     * @param user The address of the user
     * @return The balance of the user
     */
    function getUserBalance(address user) public view returns (uint256) {
        require(user != address(0), "Invalid address");
        return userBalances[user];
    }

    /**
     * @dev Retrieve the list of all users
     * @return An array of user addresses
     */
    function getUserList() public view returns (address[] memory) {
        return userList;
    }

    /**
     * @dev Change the owner of the contract
     * @param newOwner The new owner's address
     */
    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
}