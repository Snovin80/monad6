// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract TaskDependencyManager {
    struct Task {
        string description;
        bool completed;
        uint256[] dependencies;
    }

    mapping(uint256 => Task) public tasks;
    uint256 public taskCount;

    event TaskCreated(uint256 indexed taskId, string description);
    event TaskCompleted(uint256 indexed taskId);
    event DependencyAdded(uint256 indexed taskId, uint256 indexed dependencyId);

    function createTask(string memory _description) public {
        taskCount++;
        tasks[taskCount] = Task({
            description: _description,
            completed: false,
            dependencies: new uint256[](0)
        });
        emit TaskCreated(taskCount, _description);
    }

    function addDependency(uint256 _taskId, uint256 _dependencyId) public {
        require(tasks[_taskId].dependencies.length < 10, "Too many dependencies");
        tasks[_taskId].dependencies.push(_dependencyId);
        emit DependencyAdded(_taskId, _dependencyId);
    }

    function completeTask(uint256 _taskId) public {
        require(!tasks[_taskId].completed, "Task already completed");
        for (uint256 i = 0; i < tasks[_taskId].dependencies.length; i++) {
            require(tasks[tasks[_taskId].dependencies[i]].completed, "Dependency not completed");
        }
        tasks[_taskId].completed = true;
        emit TaskCompleted(_taskId);
    }

    function getTask(uint256 _taskId) public view returns (string memory description, bool completed, uint256[] memory dependencies) {
        Task memory task = tasks[_taskId];
        return (task.description, task.completed, task.dependencies);
    }
}