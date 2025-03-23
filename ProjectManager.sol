// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract ProjectManager {
    struct Project {
        string name;
        string description;
        address owner;
        uint256 budget;
        bool completed;
    }

    mapping(uint256 => Project) public projects;
    uint256 public projectCount;

    event ProjectCreated(uint256 indexed projectId, string name, string description, address owner, uint256 budget);
    event ProjectCompleted(uint256 indexed projectId);

    modifier onlyOwner(uint256 _projectId) {
        require(projects[_projectId].owner == msg.sender, "Not the project owner");
        _;
    }

    function createProject(string memory _name, string memory _description, uint256 _budget) public {
        projectCount++;
        projects[projectCount] = Project({
            name: _name,
            description: _description,
            owner: msg.sender,
            budget: _budget,
            completed: false
        });
        emit ProjectCreated(projectCount, _name, _description, msg.sender, _budget);
    }

    function completeProject(uint256 _projectId) public onlyOwner(_projectId) {
        projects[_projectId].completed = true;
        emit ProjectCompleted(_projectId);
    }

    function getProject(uint256 _projectId) public view returns (string memory name, string memory description, address owner, uint256 budget, bool completed) {
        Project memory project = projects[_projectId];
        return (project.name, project.description, project.owner, project.budget, project.completed);
    }
}