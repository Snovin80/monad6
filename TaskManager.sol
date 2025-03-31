// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract TaskManager {
    struct Task {
        string description;
        bool completed;
    }

    mapping(uint256 => Task) public tasks;
    uint256 public taskId;

    event TaskCreated(uint256 indexed id, string description);
    event TaskCompleted(uint256 indexed id);

    function createTask(string memory _description) public {
        taskId++;
        tasks[taskId] = Task(_description, false);
        emit TaskCreated(taskId, _description);
    }

    function completeTask(uint256 _id) public {
        require(!tasks[_id].completed, "Task already completed");
        tasks[_id].completed = true;
        emit TaskCompleted(_id);
    }

    function getTask(uint256 _id) public view returns (string memory, bool) {
        return (tasks[_id].description, tasks[_id].completed);
    }
}