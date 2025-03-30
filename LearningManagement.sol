// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract LearningManagement {
    struct Course {
        string title;
        string description;
        address instructor;
        uint256 startDate;
        uint256 endDate;
        bool completed;
        Lesson[] lessons;
    }

    struct Lesson {
        string title;
        string contentHash;
        uint256 duration;
        bool completed;
        mapping(address => bool) completions;
        string[] comments;
    }

    struct Certificate {
        string courseTitle;
        string student;
        uint256 issueDate;
        bool valid;
    }

    mapping(uint256 => Course) public courses;
    mapping(uint256 => mapping(address => Certificate)) public certificates;
    uint256 public courseCount;

    address public owner;

    event CourseStarted(uint256 indexed courseId, string title, string description, address instructor, uint256 startDate, uint256 endDate);
    event LessonAdded(uint256 indexed courseId, uint256 indexed lessonId, string title, string contentHash, uint256 duration);
    event LessonCompleted(uint256 indexed courseId, uint256 indexed lessonId, address indexed student);
    event CommentAdded(uint256 indexed courseId, uint256 indexed lessonId, address commenter, string comment);
    event CertificateIssued(uint256 indexed courseId, address indexed student, string courseTitle, uint256 issueDate);
    event CertificateRevoked(uint256 indexed courseId, address indexed student);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyInstructor(uint256 _courseId) {
        require(courses[_courseId].instructor == msg.sender, "Only instructor can perform this action");
        _;
    }

    modifier onlyStudent(uint256 _courseId, uint256 _lessonId) {
        require(courses[_courseId].lessons[_lessonId].completions[msg.sender], "Lesson not completed");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function startCourse(string memory _title, string memory _description, uint256 _startDate, uint256 _endDate) public onlyOwner {
        require(_startDate < _endDate, "Invalid date range");
        courseCount++;
        Course storage newCourse = courses[courseCount];
        newCourse.title = _title;
        newCourse.description = _description;
        newCourse.instructor = msg.sender;
        newCourse.startDate = _startDate;
        newCourse.endDate = _endDate;
        newCourse.completed = false;
        emit CourseStarted(courseCount, _title, _description, msg.sender, _startDate, _endDate);
    }

    function addLesson(uint256 _courseId, string memory _title, string memory _contentHash, uint256 _duration) public onlyInstructor(_courseId) {
        Course storage course = courses[_courseId];
        require(!course.completed, "Course already completed");
        course.lessons.push(Lesson({
            title: _title,
            contentHash: _contentHash,
            duration: _duration,
            completed: false,
            completions: new mapping(address => bool),
            comments: new string[](0)
        }));
        emit LessonAdded(_courseId, course.lessons.length - 1, _title, _contentHash, _duration);
    }

    function completeLesson(uint256 _courseId, uint256 _lessonId) public {
        Course storage course = courses[_courseId];
        Lesson storage lesson = course.lessons[_lessonId];
        require(!lesson.completed, "Lesson already completed");
        lesson.completions[msg.sender] = true;
        emit LessonCompleted(_courseId, _lessonId, msg.sender);

        // Check if all lessons in the course are completed
        bool allLessonsCompleted = true;
        for (uint256 i = 0; i < course.lessons.length; i++) {
            if (!course.lessons[i].completions[msg.sender]) {
                allLessonsCompleted = false;
                break;
            }
        }
        if (allLessonsCompleted) {
            course.completed = true;
            issueCertificate(_courseId, msg.sender);
        }
    }

    function addComment(uint256 _courseId, uint256 _lessonId, string memory _comment) public {
        Course storage course = courses[_courseId];
        Lesson storage lesson = course.lessons[_lessonId];
        require(!lesson.completed, "Lesson already completed");
        lesson.comments.push(_comment);
        emit CommentAdded(_courseId, _lessonId, msg.sender, _comment);
    }

    function issueCertificate(uint256 _courseId, address _student) internal {
        Course storage course = courses[_courseId];
        require(course.completed, "Course not completed");
        require(!certificates[_courseId][_student].valid, "Certificate already issued");

        certificates[_courseId][_student] = Certificate({
            courseTitle: course.title,
            student: addressToString(_student),
            issueDate: block.timestamp,
            valid: true
        });
        emit CertificateIssued(_courseId, _student, course.title, block.timestamp);
    }

    function revokeCertificate(uint256 _courseId, address _student) public onlyOwner {
        require(certificates[_courseId][_student].valid, "Certificate already revoked");
        certificates[_courseId][_student].valid = false;
        emit CertificateRevoked(_courseId, _student);
    }

    function getCourse(uint256 _courseId) public view returns (
        string memory title,
        string memory description,
        address instructor,
        uint256 startDate,
        uint256 endDate,
        bool completed,
        Lesson[] memory lessons
    ) {
        Course storage course = courses[_courseId];
        return (course.title, course.description, course.instructor, course.startDate, course.endDate, course.completed, course.lessons);
    }

    function getLesson(uint256 _courseId, uint256 _lessonId) public view returns (
        string memory title,
        string memory contentHash,
        uint256 duration,
        bool completed,
        string[] memory comments
    ) {
        Lesson storage lesson = courses[_courseId].lessons[_lessonId];
        return (lesson.title, lesson.contentHash, lesson.duration, lesson.completed, lesson.comments);
    }

    function hasCompletedLesson(uint256 _courseId, uint256 _lessonId, address _student) public view returns (bool) {
        return courses[_courseId].lessons[_lessonId].completions[_student];
    }

    function getCertificate(uint256 _courseId, address _student) public view returns (
        string memory courseTitle,
        string memory student,
        uint256 issueDate,
        bool valid
    ) {
        Certificate storage certificate = certificates[_courseId][_student];
        return (certificate.courseTitle, certificate.student, certificate.issueDate, certificate.valid);
    }

    function addressToString(address _addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
}