// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract StockManagementWithVoting {
    struct Stock {
        string symbol;
        string name;
        uint256 totalSupply;
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
    }

    struct Vote {
        string proposal;
        mapping(address => bool) hasVoted;
        mapping(address => bool) votedFor;
        uint256 yesVotes;
        uint256 noVotes;
        bool ended;
    }

    Stock public stock;
    mapping(uint256 => Vote) public votes;
    uint256 public voteCount;

    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event VoteCreated(uint256 indexed voteId, string proposal);
    event Voted(uint256 indexed voteId, address indexed voter, bool vote);
    event VoteEnded(uint256 indexed voteId, bool result);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor(string memory _symbol, string memory _name, uint256 _totalSupply) {
        owner = msg.sender;
        stock.symbol = _symbol;
        stock.name = _name;
        stock.totalSupply = _totalSupply;
        stock.balances[msg.sender] = _totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(stock.balances[msg.sender] >= _value, "Insufficient balance");
        stock.balances[msg.sender] -= _value;
        stock.balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        stock.allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(stock.balances[_from] >= _value, "Insufficient balance");
        require(stock.allowances[_from][msg.sender] >= _value, "Allowance exceeded");
        stock.balances[_from] -= _value;
        stock.allowances[_from][msg.sender] -= _value;
        stock.balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return stock.balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return stock.allowances[_owner][_spender];
    }

    function createVote(string memory _proposal) public onlyOwner {
        voteCount++;
        votes[voteCount] = Vote({
            proposal: _proposal,
            hasVoted: new mapping(address => bool),
            votedFor: new mapping(address => bool),
            yesVotes: 0,
            noVotes: 0,
            ended: false
        });
        emit VoteCreated(voteCount, _proposal);
    }

    function vote(uint256 _voteId, bool _vote) public {
        Vote storage currentVote = votes[_voteId];
        require(!currentVote.hasVoted[msg.sender], "Already voted");
        require(!currentVote.ended, "Vote ended");

        currentVote.hasVoted[msg.sender] = true;
        if (_vote) {
            currentVote.yesVotes++;
            currentVote.votedFor[msg.sender] = true;
        } else {
            currentVote.noVotes++;
        }
        emit Voted(_voteId, msg.sender, _vote);
    }

    function endVote(uint256 _voteId) public onlyOwner {
        Vote storage currentVote = votes[_voteId];
        require(!currentVote.ended, "Vote already ended");
        currentVote.ended = true;
        bool result = currentVote.yesVotes > currentVote.noVotes;
        emit VoteEnded(_voteId, result);
    }

    function getVote(uint256 _voteId) public view returns (
        string memory proposal,
        uint256 yesVotes,
        uint256 noVotes,
        bool ended
    ) {
        Vote storage currentVote = votes[_voteId];
        return (currentVote.proposal, currentVote.yesVotes, currentVote.noVotes, currentVote.ended);
    }

    function hasVoted(uint256 _voteId, address _voter) public view returns (bool) {
        return votes[_voteId].hasVoted[_voter];
    }

    function votedFor(uint256 _voteId, address _voter) public view returns (bool) {
        return votes[_voteId].votedFor[_voter];
    }
}