// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract ComplexContestPlatform {
    struct Contest {
        string title;
        string description;
        uint256 entryFee; // Символическое значение (не используется для движения средств)
        uint256 deadline;
        bool active;
        mapping(address => Entry) entries;
        address[] participants;
        mapping(address => uint256) scores;
        mapping(address => bool) judges;
    }

    struct Entry {
        string submissionHash;
        uint256 timestamp;
        bool judged;
        uint256 score;
        string[] comments;
    }

    mapping(uint256 => Contest) public contests;
    uint256 public contestCount;

    address public owner;

    event ContestCreated(uint256 indexed contestId, string title, string description, uint256 deadline);
    event EntrySubmitted(uint256 indexed contestId, address indexed participant, string submissionHash);
    event EntryJudged(uint256 indexed contestId, address indexed participant, uint256 score, string comment);
    event JudgeAdded(address indexed judge);
    event JudgeRemoved(address indexed judge);
    event ContestClosed(uint256 indexed contestId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyJudge(uint256 _contestId) {
        require(contests[_contestId].judges[msg.sender], "Only judge can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createContest(
        string memory _title,
        string memory _description,
        uint256 _entryFee,
        uint256 _deadline
    ) public onlyOwner {
        require(_deadline > block.timestamp, "Deadline must be in the future");
        contestCount++;
        Contest storage newContest = contests[contestCount];
        newContest.title = _title;
        newContest.description = _description;
        newContest.entryFee = _entryFee;
        newContest.deadline = _deadline;
        newContest.active = true;
        emit ContestCreated(contestCount, _title, _description, _deadline);
    }

    function submitEntry(uint256 _contestId, string memory _submissionHash) public {
        Contest storage contest = contests[_contestId];
        require(contest.active, "Contest is not active");
        require(block.timestamp < contest.deadline, "Submission deadline has passed");
        require(bytes(contest.entries[msg.sender].submissionHash).length == 0, "Already submitted an entry");

        contest.entries[msg.sender] = Entry({
            submissionHash: _submissionHash,
            timestamp: block.timestamp,
            judged: false,
            score: 0,
            comments: new string[](0)
        });
        contest.participants.push(msg.sender);
        emit EntrySubmitted(_contestId, msg.sender, _submissionHash);
    }

    function addJudge(uint256 _contestId, address _judge) public onlyOwner {
        Contest storage contest = contests[_contestId];
        require(!contest.judges[_judge], "Judge already added");
        contest.judges[_judge] = true;
        emit JudgeAdded(_judge);
    }

    function removeJudge(uint256 _contestId, address _judge) public onlyOwner {
        Contest storage contest = contests[_contestId];
        require(contest.judges[_judge], "Judge not found");
        contest.judges[_judge] = false;
        emit JudgeRemoved(_judge);
    }

    function judgeEntry(uint256 _contestId, address _participant, uint256 _score, string memory _comment) public onlyJudge(_contestId) {
        Contest storage contest = contests[_contestId];
        require(contest.active, "Contest is not active");
        require(_score >= 0 && _score <= 100, "Score must be between 0 and 100");
        require(!contest.entries[_participant].judged, "Entry already judged");

        contest.entries[_participant].judged = true;
        contest.entries[_participant].score = _score;
        contest.entries[_participant].comments.push(_comment);
        contest.scores[_participant] += _score;
        emit EntryJudged(_contestId, _participant, _score, _comment);
    }

    function closeContest(uint256 _contestId) public onlyOwner {
        Contest storage contest = contests[_contestId];
        require(contest.active, "Contest is not active");
        require(block.timestamp >= contest.deadline, "Contest deadline has not passed");

        contest.active = false;
        emit ContestClosed(_contestId);
    }

    function getContest(uint256 _contestId) public view returns (
        string memory title,
        string memory description,
        uint256 entryFee,
        uint256 deadline,
        bool active
    ) {
        Contest storage contest = contests[_contestId];
        return (contest.title, contest.description, contest.entryFee, contest.deadline, contest.active);
    }

    function getEntry(uint256 _contestId, address _participant) public view returns (
        string memory submissionHash,
        uint256 timestamp,
        bool judged,
        uint256 score,
        string[] memory comments
    ) {
        Contest storage contest = contests[_contestId];
        Entry storage entry = contest.entries[_participant];
        return (entry.submissionHash, entry.timestamp, entry.judged, entry.score, entry.comments);
    }

    function getParticipants(uint256 _contestId) public view returns (address[] memory) {
        return contests[_contestId].participants;
    }

    function getScores(uint256 _contestId) public view returns (address[] memory, uint256[] memory) {
        Contest storage contest = contests[_contestId];
        address[] memory participantsList = contest.participants;
        uint256[] memory scoresList = new uint256[](participantsList.length);

        for (uint256 i = 0; i < participantsList.length; i++) {
            scoresList[i] = contest.scores[participantsList[i]];
        }

        return (participantsList, scoresList);
    }

    function getJudges(uint256 _contestId) public view returns (address[] memory) {
        Contest storage contest = contests[_contestId];
        address[] memory judgesList = new address[](contest.participants.length);
        uint256 count = 0;

        for (uint256 i = 0; i < contest.participants.length; i++) {
            if (contest.judges[contest.participants[i]]) {
                judgesList[count] = contest.participants[i];
                count++;
            }
        }

        // Resize the array to the correct length
        assembly {
            mstore(judgesList, count)
        }

        return judgesList;
    }

    function getParticipantScores(uint256 _contestId) public view returns (address[] memory, uint256[] memory) {
        Contest storage contest = contests[_contestId];
        address[] memory participantsList = contest.participants;
        uint256[] memory scoresList = new uint256[](participantsList.length);

        for (uint256 i = 0; i < participantsList.length; i++) {
            scoresList[i] = contest.scores[participantsList[i]];
        }

        return (participantsList, scoresList);
    }

    function getParticipantComments(uint256 _contestId, address _participant) public view returns (string[] memory) {
        return contests[_contestId].entries[_participant].comments;
    }

    function getContestDetails(uint256 _contestId) public view returns (
        string memory title,
        string memory description,
        uint256 entryFee,
        uint256 deadline,
        bool active,
        address[] memory participants,
        uint256[] memory scores,
        string[][] memory comments
    ) {
        Contest storage contest = contests[_contestId];
        participants = contest.participants;
        scores = new uint256[](participants.length);
        comments = new string[][](participants.length);

        for (uint256 i = 0; i < participants.length; i++) {
            scores[i] = contest.scores[participants[i]];
            comments[i] = contest.entries[participants[i]].comments;
        }

        return (contest.title, contest.description, contest.entryFee, contest.deadline, contest.active, participants, scores, comments);
    }

    function getContestJudges(uint256 _contestId) public view returns (address[] memory) {
        Contest storage contest = contests[_contestId];
        address[] memory judgesList = new address[](contest.participants.length);
        uint256 count = 0;

        for (uint256 i = 0; i < contest.participants.length; i++) {
            if (contest.judges[contest.participants[i]]) {
                judgesList[count] = contest.participants[i];
                count++;
            }
        }

        // Resize the array to the correct length
        assembly {
            mstore(judgesList, count)
        }

        return judgesList;
    }

    function getContestScores(uint256 _contestId) public view returns (address[] memory, uint256[] memory) {
        Contest storage contest = contests[_contestId];
        address[] memory participantsList = contest.participants;
        uint256[] memory scoresList = new uint256[](participantsList.length);

        for (uint256 i = 0; i < participantsList.length; i++) {
            scoresList[i] = contest.scores[participantsList[i]];
        }

        return (participantsList, scoresList);
    }

    function getContestComments(uint256 _contestId) public view returns (address[] memory, string[][] memory) {
        Contest storage contest = contests[_contestId];
        address[] memory participantsList = contest.participants;
        string[][] memory commentsList = new string[][](participantsList.length);

        for (uint256 i = 0; i < participantsList.length; i++) {
            commentsList[i] = contest.entries[participantsList[i]].comments;
        }

        return (participantsList, commentsList);
    }
}