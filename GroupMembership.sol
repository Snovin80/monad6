// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract GroupMembership {
    struct Group {
        string name;
        string description;
        address[] members;
    }

    mapping(uint256 => Group) public groups;
    uint256 public groupCount;

    event GroupCreated(uint256 indexed groupId, string name, string description);
    event MemberAdded(uint256 indexed groupId, address indexed member);
    event MemberRemoved(uint256 indexed groupId, address indexed member);

    function createGroup(string memory _name, string memory _description) public {
        groupCount++;
        groups[groupCount] = Group({
            name: _name,
            description: _description,
            members: new address[](0)
        });
        emit GroupCreated(groupCount, _name, _description);
    }

    function addMember(uint256 _groupId, address _member) public {
        require(isMember(_groupId, _member) == false, "Member already exists");
        groups[_groupId].members.push(_member);
        emit MemberAdded(_groupId, _member);
    }

    function removeMember(uint256 _groupId, address _member) public {
        require(isMember(_groupId, _member) == true, "Member does not exist");
        for (uint256 i = 0; i < groups[_groupId].members.length; i++) {
            if (groups[_groupId].members[i] == _member) {
                groups[_groupId].members[i] = groups[_groupId].members[groups[_groupId].members.length - 1];
                groups[_groupId].members.pop();
                emit MemberRemoved(_groupId, _member);
                break;
            }
        }
    }

    function isMember(uint256 _groupId, address _member) public view returns (bool) {
        for (uint256 i = 0; i < groups[_groupId].members.length; i++) {
            if (groups[_groupId].members[i] == _member) {
                return true;
            }
        }
        return false;
    }

    function getGroup(uint256 _groupId) public view returns (string memory name, string memory description, address[] memory members) {
        Group memory group = groups[_groupId];
        return (group.name, group.description, group.members);
    }
}