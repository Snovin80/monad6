// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract MultiChoiceVoting {
    struct Option {
        string name;
        uint256 voteCount;
    }

    struct Vote {
        address voter;
        uint256 optionId;
    }

    Option[] public options;
    Vote[] public votes;

    event OptionAdded(uint256 indexed optionId, string name);
    event Voted(uint256 indexed optionId, address indexed voter);

    constructor(string[] memory _optionNames) {
        for (uint256 i = 0; i < _optionNames.length; i++) {
            options.push(Option({
                name: _optionNames[i],
                voteCount: 0
            }));
            emit OptionAdded(i, _optionNames[i]);
        }
    }

    function vote(uint256 _optionId) public {
        require(_optionId < options.length, "Invalid option ID");
        options[_optionId].voteCount += 1;
        votes.push(Vote({
            voter: msg.sender,
            optionId: _optionId
        }));
        emit Voted(_optionId, msg.sender);
    }

    function getOption(uint256 _optionId) public view returns (string memory name, uint256 voteCount) {
        Option memory option = options[_optionId];
        return (option.name, option.voteCount);
    }

    function getTotalVotes() public view returns (uint256) {
        return votes.length;
    }
}