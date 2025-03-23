// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract TaskManager {
    struct Task {
        string description;
        uint256 priority;
        bool completed;
    }

    mapping(uint256 => Task) public tasks;
    uint256 public taskCount;

    event TaskCreated(uint256 indexed taskId, string description, uint256 priority);
    event TaskCompleted(uint256 indexed taskId);
    event TaskPriorityUpdated(uint256 indexed taskId, uint256 newPriority);

    function createTask(string memory _description, uint256 _priority) public {
        taskCount++;
        tasks[taskCount] = Task({
            description: _description,
            priority: _priority,
            completed: false
        });
        emit TaskCreated(taskCount, _description, _priority);
    }

    function completeTask(uint256 _taskId) public {
        require(!tasks[_taskId].completed, "Task already completed");
        tasks[_taskId].completed = true;
        emit TaskCompleted(_taskId);
    }

    function updateTaskPriority(uint256 _taskId, uint256 _newPriority) public {
        require(!tasks[_taskId].completed, "Task already completed");
        tasks[_taskId].priority = _newPriority;
        emit TaskPriorityUpdated(_taskId, _newPriority);
    }

    function getTask(uint256 _taskId) public view returns (string memory description, uint256 priority, bool completed) {
        Task memory task = tasks[_taskId];
        return (task.description, task.priority, task.completed);
    }
}