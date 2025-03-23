// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract TaskChainManager {
    struct Task {
        string description;
        uint256 deadline;
        bool completed;
        uint256[] dependencies;
    }

    mapping(uint256 => Task) public tasks;
    uint256 public taskCount;

    event TaskCreated(uint256 indexed taskId, string description, uint256 deadline);
    event DependencyAdded(uint256 indexed taskId, uint256 indexed dependencyId);
    event TaskCompleted(uint256 indexed taskId);

    function createTask(string memory _description, uint256 _deadline) public {
        require(_deadline > block.timestamp, "Deadline must be in the future");
        taskCount++;
        tasks[taskCount] = Task({
            description: _description,
            deadline: _deadline,
            completed: false,
            dependencies: new uint256[](0)
        });
        emit TaskCreated(taskCount, _description, _deadline);
    }

    function addDependency(uint256 _taskId, uint256 _dependencyId) public {
        require(tasks[_taskId].dependencies.length < 10, "Too many dependencies");
        tasks[_taskId].dependencies.push(_dependencyId);
        emit DependencyAdded(_taskId, _dependencyId);
    }

    function completeTask(uint256 _taskId) public {
        require(!tasks[_taskId].completed, "Task already completed");
        require(block.timestamp <= tasks[_taskId].deadline, "Task deadline has passed");
        for (uint256 i = 0; i < tasks[_taskId].dependencies.length; i++) {
            require(tasks[tasks[_taskId].dependencies[i]].completed, "Dependency not completed");
        }
        tasks[_taskId].completed = true;
        emit TaskCompleted(_taskId);
    }

    function getTask(uint256 _taskId) public view returns (string memory description, uint256 deadline, bool completed, uint256[] memory dependencies) {
        Task memory task = tasks[_taskId];
        return (task.description, task.deadline, task.completed, task.dependencies);
    }
}