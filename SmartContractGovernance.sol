// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

contract SmartContractGovernance {
    struct Rule {
        string description;
        bool isActive;
    }

    mapping(uint256 => Rule) public rules;
    uint256 public ruleCount;

    event RuleAdded(uint256 ruleId, string description);
    event RuleUpdated(uint256 ruleId, bool isActive);

    function addRule(string memory _description) public {
        rules[ruleCount] = Rule(_description, true);
        emit RuleAdded(ruleCount, _description);
        ruleCount++;
    }

    function updateRule(uint256 _ruleId, bool _isActive) public {
        require(_ruleId < ruleCount, "Rule does not exist");
        rules[_ruleId].isActive = _isActive;
        emit RuleUpdated(_ruleId, _isActive);
    }

    function getRule(uint256 _ruleId) public view returns (string memory, bool) {
        require(_ruleId < ruleCount, "Rule does not exist");
        Rule memory rule = rules[_ruleId];
        return (rule.description, rule.isActive);
    }
}