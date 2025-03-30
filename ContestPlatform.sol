// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract ContestPlatform {
    struct Contest {
        string title;
        string description;
        uint256 entryFee; // Символическое значение (не используется для движения средств)
        uint256 deadline;
        bool active;
        mapping(address => Entry) entries;
        address[] participants;
    }

    struct Entry {
        string submissionHash;
        uint256 timestamp;
        bool judged;
        uint256 score;
    }

    mapping(uint256 => Contest) public contests;
    uint256 public contestCount;

    event ContestCreated(uint256 indexed contestId, string title, string description, uint256 deadline);
    event EntrySubmitted(uint256 indexed contestId, address indexed participant, string submissionHash);
    event EntryJudged(uint256 indexed contestId, address indexed participant, uint256 score);
    event ContestClosed(uint256 indexed contestId);

    /**
     * @dev Создание нового конкурса
     * @param _title Название конкурса
     * @param _description Описание конкурса
     * @param _entryFee Символическая стоимость участия (не используется для движения средств)
     * @param _deadline Дата окончания приема заявок
     */
    function createContest(
        string memory _title,
        string memory _description,
        uint256 _entryFee,
        uint256 _deadline
    ) public {
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

    /**
     * @dev Подача заявки на конкурс
     * @param _contestId Идентификатор конкурса
     * @param _submissionHash Хэш поданной работы
     */
    function submitEntry(uint256 _contestId, string memory _submissionHash) public {
        Contest storage contest = contests[_contestId];
        require(contest.active, "Contest is not active");
        require(block.timestamp < contest.deadline, "Submission deadline has passed");
        require(bytes(contest.entries[msg.sender].submissionHash).length == 0, "Already submitted an entry");

        contest.entries[msg.sender] = Entry({
            submissionHash: _submissionHash,
            timestamp: block.timestamp,
            judged: false,
            score: 0
        });
        contest.participants.push(msg.sender);
        emit EntrySubmitted(_contestId, msg.sender, _submissionHash);
    }

    /**
     * @dev Оценка заявки жюри
     * @param _contestId Идентификатор конкурса
     * @param _participant Адрес участника
     * @param _score Оценка (от 0 до 100)
     */
    function judgeEntry(uint256 _contestId, address _participant, uint256 _score) public onlyOwner {
        Contest storage contest = contests[_contestId];
        require(contest.active, "Contest is not active");
        require(_score >= 0 && _score <= 100, "Score must be between 0 and 100");
        require(!contest.entries[_participant].judged, "Entry already judged");

        contest.entries[_participant].judged = true;
        contest.entries[_participant].score = _score;
        emit EntryJudged(_contestId, _participant, _score);
    }

    /**
     * @dev Закрытие конкурса
     * @param _contestId Идентификатор конкурса
     */
    function closeContest(uint256 _contestId) public onlyOwner {
        Contest storage contest = contests[_contestId];
        require(contest.active, "Contest is not active");
        require(block.timestamp >= contest.deadline, "Contest deadline has not passed");

        contest.active = false;
        emit ContestClosed(_contestId);
    }

    /**
     * @dev Получить информацию о конкурсе
     * @param _contestId Идентификатор конкурса
     * @return title Название конкурса
     * @return description Описание конкурса
     * @return entryFee Символическая стоимость участия
     * @return deadline Дата окончания приема заявок
     * @return active Флаг активности конкурса
     */
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

    /**
     * @dev Получить информацию о заявке
     * @param _contestId Идентификатор конкурса
     * @param _participant Адрес участника
     * @return submissionHash Хэш поданной работы
     * @return timestamp Время подачи заявки
     * @return judged Флаг оценки заявки
     * @return score Оценка заявки
     */
    function getEntry(uint256 _contestId, address _participant) public view returns (
        string memory submissionHash,
        uint256 timestamp,
        bool judged,
        uint256 score
    ) {
        Contest storage contest = contests[_contestId];
        Entry storage entry = contest.entries[_participant];
        return (entry.submissionHash, entry.timestamp, entry.judged, entry.score);
    }

    /**
     * @dev Получить список участников конкурса
     * @param _contestId Идентификатор конкурса
     * @return participants Список адресов участников
     */
    function getParticipants(uint256 _contestId) public view returns (address[] memory) {
        return contests[_contestId].participants;
    }

    /**
     * @dev Модификатор для проверки прав владельца контракта
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    address private owner;

    constructor() {
        owner = msg.sender;
    }
}