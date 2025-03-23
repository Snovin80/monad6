// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract RatingSystem {
    struct User {
        string username;
        uint256 rating;
        uint256 numberOfVotes;
    }

    mapping(address => User) public users;
    address[] public userList;

    event UserAdded(address indexed user, string username);
    event RatingUpdated(address indexed user, uint256 newRating);

    function addUser(string memory _username) public {
        require(bytes(users[msg.sender].username).length == 0, "User already exists");
        users[msg.sender] = User({
            username: _username,
            rating: 0,
            numberOfVotes: 0
        });
        userList.push(msg.sender);
        emit UserAdded(msg.sender, _username);
    }

    function rateUser(address _user, uint256 _rating) public {
        require(bytes(users[_user].username).length != 0, "User does not exist");
        require(_rating >= 0 && _rating <= 10, "Invalid rating");

        User storage user = users[_user];
        user.rating = (user.rating * user.numberOfVotes + _rating) / (user.numberOfVotes + 1);
        user.numberOfVotes += 1;
        emit RatingUpdated(_user, user.rating);
    }

    function getUserInfo(address _user) public view returns (string memory username, uint256 rating, uint256 numberOfVotes) {
        User memory user = users[_user];
        return (user.username, user.rating, user.numberOfVotes);
    }
}