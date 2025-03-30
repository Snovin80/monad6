// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract ProjectManagement {
    struct Project {
        string title;
        string description;
        address manager;
        uint256 startDate;
        uint256 endDate;
        bool completed;
        Stage[] stages;
    }

    struct Stage {
        string name;
        string description;
        uint256 deadline;
        bool completed;
        Task[] tasks;
    }

    struct Task {
        string title;
        string description;
        address assignee;
        bool completed;
        uint256 completionDate;
        string[] comments;
    }

    mapping(uint256 => Project) public projects;
    uint256 public projectCount;

    address public owner;

    event ProjectStarted(uint256 indexed projectId, string title, string description, address manager, uint256 startDate, uint256 endDate);
    event StageAdded(uint256 indexed projectId, uint256 indexed stageId, string name, string description, uint256 deadline);
    event TaskAdded(uint256 indexed projectId, uint256 indexed stageId, uint256 indexed taskId, string title, string description, address assignee);
    event TaskCompleted(uint256 indexed projectId, uint256 indexed stageId, uint256 indexed taskId, address completer);
    event CommentAdded(uint256 indexed projectId, uint256 indexed stageId, uint256 indexed taskId, address commenter, string comment);
    event ProjectCompleted(uint256 indexed projectId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyManager(uint256 _projectId) {
        require(projects[_projectId].manager == msg.sender, "Only project manager can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function startProject(string memory _title, string memory _description, uint256 _startDate, uint256 _endDate) public onlyOwner {
        require(_startDate < _endDate, "Invalid date range");
        projectCount++;
        Project storage newProject = projects[projectCount];
        newProject.title = _title;
        newProject.description = _description;
        newProject.manager = msg.sender;
        newProject.startDate = _startDate;
        newProject.endDate = _endDate;
        newProject.completed = false;
        emit ProjectStarted(projectCount, _title, _description, msg.sender, _startDate, _endDate);
    }

    function addStage(uint256 _projectId, string memory _name, string memory _description, uint256 _deadline) public onlyManager(_projectId) {
        Project storage project = projects[_projectId];
        require(!project.completed, "Project already completed");
        project.stages.push(Stage({
            name: _name,
            description: _description,
            deadline: _deadline,
            completed: false,
            tasks: new Task[](0)
        }));
        emit StageAdded(_projectId, project.stages.length - 1, _name, _description, _deadline);
    }

    function addTask(uint256 _projectId, uint256 _stageId, string memory _title, string memory _description, address _assignee) public onlyManager(_projectId) {
        Project storage project = projects[_projectId];
        require(!project.completed, "Project already completed");
        require(!project.stages[_stageId].completed, "Stage already completed");
        project.stages[_stageId].tasks.push(Task({
            title: _title,
            description: _description,
            assignee: _assignee,
            completed: false,
            completionDate: 0,
            comments: new string[](0)
        }));
        emit TaskAdded(_projectId, _stageId, project.stages[_stageId].tasks.length - 1, _title, _description, _assignee);
    }

    function completeTask(uint256 _projectId, uint256 _stageId, uint256 _taskId) public {
        Project storage project = projects[_projectId];
        Stage storage stage = project.stages[_stageId];
        Task storage task = stage.tasks[_taskId];
        require(task.assignee == msg.sender, "Not assigned to this task");
        require(!task.completed, "Task already completed");
        task.completed = true;
        task.completionDate = block.timestamp;
        emit TaskCompleted(_projectId, _stageId, _taskId, msg.sender);

        // Check if all tasks in the stage are completed
        bool allTasksCompleted = true;
        for (uint256 i = 0; i < stage.tasks.length; i++) {
            if (!stage.tasks[i].completed) {
                allTasksCompleted = false;
                break;
            }
        }
        if (allTasksCompleted) {
            stage.completed = true;
        }

        // Check if all stages in the project are completed
        allTasksCompleted = true;
        for (uint256 i = 0; i < project.stages.length; i++) {
            if (!project.stages[i].completed) {
                allTasksCompleted = false;
                break;
            }
        }
        if (allTasksCompleted) {
            project.completed = true;
            emit ProjectCompleted(_projectId);
        }
    }

    function addComment(uint256 _projectId, uint256 _stageId, uint256 _taskId, string memory _comment) public {
        Project storage project = projects[_projectId];
        Stage storage stage = project.stages[_stageId];
        Task storage task = stage.tasks[_taskId];
        require(!task.completed, "Task already completed");
        task.comments.push(_comment);
        emit CommentAdded(_projectId, _stageId, _taskId, msg.sender, _comment);
    }

    function getProject(uint256 _projectId) public view returns (
        string memory title,
        string memory description,
        address manager,
        uint256 startDate,
        uint256 endDate,
        bool completed,
        Stage[] memory stages
    ) {
        Project storage project = projects[_projectId];
        return (project.title, project.description, project.manager, project.startDate, project.endDate, project.completed, project.stages);
    }

    function getStage(uint256 _projectId, uint256 _stageId) public view returns (
        string memory name,
        string memory description,
        uint256 deadline,
        bool completed,
        Task[] memory tasks
    ) {
        Stage storage stage = projects[_projectId].stages[_stageId];
        return (stage.name, stage.description, stage.deadline, stage.completed, stage.tasks);
    }

    function getTask(uint256 _projectId, uint256 _stageId, uint256 _taskId) public view returns (
        string memory title,
        string memory description,
        address assignee,
        bool completed,
        uint256 completionDate,
        string[] memory comments
    ) {
        Task storage task = projects[_projectId].stages[_stageId].tasks[_taskId];
        return (task.title, task.description, task.assignee, task.completed, task.completionDate, task.comments);
    }
}