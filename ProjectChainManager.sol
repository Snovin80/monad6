// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract ProjectChainManager {
    struct Project {
        string name;
        string description;
        uint256[] dependencies;
        bool completed;
    }

    mapping(uint256 => Project) public projects;
    uint256 public projectCount;

    event ProjectCreated(uint256 indexed projectId, string name, string description);
    event DependencyAdded(uint256 indexed projectId, uint256 indexed dependencyId);
    event ProjectCompleted(uint256 indexed projectId);

    function createProject(string memory _name, string memory _description) public {
        projectCount++;
        projects[projectCount] = Project({
            name: _name,
            description: _description,
            dependencies: new uint256[](0),
            completed: false
        });
        emit ProjectCreated(projectCount, _name, _description);
    }

    function addDependency(uint256 _projectId, uint256 _dependencyId) public {
        require(projects[_projectId].dependencies.length < 10, "Too many dependencies");
        projects[_projectId].dependencies.push(_dependencyId);
        emit DependencyAdded(_projectId, _dependencyId);
    }

    function completeProject(uint256 _projectId) public {
        require(!projects[_projectId].completed, "Project already completed");
        for (uint256 i = 0; i < projects[_projectId].dependencies.length; i++) {
            require(projects[projects[_projectId].dependencies[i]].completed, "Dependency not completed");
        }
        projects[_projectId].completed = true;
        emit ProjectCompleted(_projectId);
    }

    function getProject(uint256 _projectId) public view returns (string memory name, string memory description, bool completed, uint256[] memory dependencies) {
        Project memory project = projects[_projectId];
        return (project.name, project.description, project.completed, project.dependencies);
    }
}