// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract UserInfo {
    struct User {
        string name;
        uint256 age;
    }

    mapping(address => User) public users;

    event UserAdded(address indexed user, string name, uint256 age);

    function addUser(string memory _name, uint256 _age) public {
        require(bytes(users[msg.sender].name).length == 0, "User already exists");
        users[msg.sender] = User(_name, _age);
        emit UserAdded(msg.sender, _name, _age);
    }

    function getUserInfo(address _user) public view returns (string memory, uint256) {
        return (users[_user].name, users[_user].age);
    }
}