// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract ReferralSystem {
    mapping(address => address) public referrals;
    mapping(address => uint256) public referralCount;

    event ReferralAdded(address indexed referrer, address indexed referee);

    function refer(address _referee) public {
        require(referrals[_referee] == address(0), "Referee already referred");
        require(_referee != msg.sender, "Cannot refer yourself");

        referrals[_referee] = msg.sender;
        referralCount[msg.sender] += 1;
        emit ReferralAdded(msg.sender, _referee);
    }

    function getReferrer(address _referee) public view returns (address) {
        return referrals[_referee];
    }

    function getReferralCount(address _referrer) public view returns (uint256) {
        return referralCount[_referrer];
    }
}