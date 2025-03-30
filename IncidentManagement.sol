// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract IncidentManagement {
    struct Incident {
        string description;
        address reporter;
        uint256 reportDate;
        string status;
        string[] comments;
        address[] handlers;
    }

    mapping(uint256 => Incident) public incidents;
    uint256 public incidentCount;

    address public owner;

    event IncidentReported(uint256 indexed incidentId, string description, address reporter);
    event IncidentStatusUpdated(uint256 indexed incidentId, string status);
    event CommentAdded(uint256 indexed incidentId, address commenter, string comment);
    event HandlerAssigned(uint256 indexed incidentId, address handler);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function reportIncident(string memory _description) public {
        incidentCount++;
        incidents[incidentCount] = Incident({
            description: _description,
            reporter: msg.sender,
            reportDate: block.timestamp,
            status: "Pending",
            comments: new string[](0),
            handlers: new address[](0)
        });
        emit IncidentReported(incidentCount, _description, msg.sender);
    }

    function updateIncidentStatus(uint256 _incidentId, string memory _status) public onlyOwner {
        Incident storage incident = incidents[_incidentId];
        require(bytes(incident.status).length > 0, "Incident does not exist");
        incident.status = _status;
        emit IncidentStatusUpdated(_incidentId, _status);
    }

    function addComment(uint256 _incidentId, string memory _comment) public {
        Incident storage incident = incidents[_incidentId];
        require(bytes(incident.status).length > 0, "Incident does not exist");
        incident.comments.push(_comment);
        emit CommentAdded(_incidentId, msg.sender, _comment);
    }

    function assignHandler(uint256 _incidentId, address _handler) public onlyOwner {
        Incident storage incident = incidents[_incidentId];
        require(bytes(incident.status).length > 0, "Incident does not exist");
        incident.handlers.push(_handler);
        emit HandlerAssigned(_incidentId, _handler);
    }

    function getIncident(uint256 _incidentId) public view returns (
        string memory description,
        address reporter,
        uint256 reportDate,
        string memory status,
        string[] memory comments,
        address[] memory handlers
    ) {
        Incident storage incident = incidents[_incidentId];
        return (incident.description, incident.reporter, incident.reportDate, incident.status, incident.comments, incident.handlers);
    }
}