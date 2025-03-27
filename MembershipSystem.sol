// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract MembershipSystem {
    struct Member {
        string name;
        string email;
        uint256 joinDate;
        bool active;
    }

    mapping(address => Member) public members;
    address[] public memberAddresses;

    event MemberJoined(address indexed memberAddress, string name, string email);
    event MemberLeft(address indexed memberAddress);

    function joinMembership(string memory _name, string memory _email) public {
        require(!members[msg.sender].active, "Already a member");
        members[msg.sender] = Member({
            name: _name,
            email: _email,
            joinDate: block.timestamp,
            active: true
        });
        memberAddresses.push(msg.sender);
        emit MemberJoined(msg.sender, _name, _email);
    }

    function leaveMembership() public {
        require(members[msg.sender].active, "Not a member");
        members[msg.sender].active = false;
        emit MemberLeft(msg.sender);
    }

    function getMember(address _memberAddress) public view returns (string memory name, string memory email, uint256 joinDate, bool active) {
        Member memory member = members[_memberAddress];
        return (member.name, member.email, member.joinDate, member.active);
    }
}