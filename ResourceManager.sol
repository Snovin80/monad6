// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract ResourceManager {
    struct Resource {
        string name;
        string description;
        bool available;
    }

    mapping(uint256 => Resource) public resources;
    uint256 public resourceCount;

    event ResourceAdded(uint256 indexed resourceId, string name, string description);
    event ResourceAllocated(uint256 indexed resourceId, address indexed allocator);
    event ResourceReleased(uint256 indexed resourceId);

    function addResource(string memory _name, string memory _description) public {
        resourceCount++;
        resources[resourceCount] = Resource({
            name: _name,
            description: _description,
            available: true
        });
        emit ResourceAdded(resourceCount, _name, _description);
    }

    function allocateResource(uint256 _resourceId) public {
        require(resources[_resourceId].available, "Resource not available");
        resources[_resourceId].available = false;
        emit ResourceAllocated(_resourceId, msg.sender);
    }

    function releaseResource(uint256 _resourceId) public {
        require(!resources[_resourceId].available, "Resource is already available");
        resources[_resourceId].available = true;
        emit ResourceReleased(_resourceId);
    }

    function getResource(uint256 _resourceId) public view returns (string memory name, string memory description, bool available) {
        Resource memory resource = resources[_resourceId];
        return (resource.name, resource.description, resource.available);
    }
}