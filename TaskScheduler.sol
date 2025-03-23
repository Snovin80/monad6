// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract TaskScheduler {
    struct Task {
        string description;
        uint256 deadline;
        bool completed;
    }

    mapping(uint256 => Task) public tasks;
    uint256 public taskCount;

    event TaskCreated(uint256 indexed taskId, string description, uint256 deadline);
    event TaskCompleted(uint256 indexed taskId);

    modifier onlyBeforeDeadline(uint256 _taskId) {
        require(block.timestamp < tasks[_taskId].deadline, "Task deadline has passed");
        _;
    }

    modifier onlyAfterDeadline(uint256 _taskId) {
        require(block.timestamp >= tasks[_taskId].deadline, "Task deadline has not passed yet");
        _;
    }

    function createTask(string memory _description, uint256 _deadline) public {
        taskCount++;
        tasks[taskCount] = Task({
            description: _description,
            deadline: _deadline,
            completed: false
        });
        emit TaskCreated(taskCount, _description, _deadline);
    }

    function completeTask(uint256 _taskId) public onlyBeforeDeadline(_taskId) {
        tasks[_taskId].completed = true;
        emit TaskCompleted(_taskId);
    }

    function getTask(uint256 _taskId) public view returns (string memory description, uint256 deadline, bool completed) {
        Task memory task = tasks[_taskId];
        return (task.description, task.deadline, task.completed);
    }
}