// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract Voting {
    mapping(string => uint256) public votes;

    event Voted(string indexed option);

    function vote(string memory _option) public {
        votes[_option]++;
        emit Voted(_option);
    }

    function getVotes(string memory _option) public view returns (uint256) {
        return votes[_option];
    }
}