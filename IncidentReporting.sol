// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract IncidentReporting {
    struct Incident {
        string description;
        address reporter;
        uint256 reportDate;
        string status;
    }

    Incident[] public incidents;

    event IncidentReported(uint256 indexed incidentId, string description, address reporter);
    event IncidentStatusUpdated(uint256 indexed incidentId, string status);

    function reportIncident(string memory _description) public {
        incidents.push(Incident({
            description: _description,
            reporter: msg.sender,
            reportDate: block.timestamp,
            status: "Pending"
        }));
        emit IncidentReported(incidents.length - 1, _description, msg.sender);
    }

    function updateIncidentStatus(uint256 _incidentId, string memory _status) public {
        Incident storage incident = incidents[_incidentId];
        require(bytes(incident.status).length > 0, "Incident does not exist");
        incident.status = _status;
        emit IncidentStatusUpdated(_incidentId, _status);
    }

    function getIncident(uint256 _incidentId) public view returns (string memory description, address reporter, uint256 reportDate, string memory status) {
        Incident memory incident = incidents[_incidentId];
        return (incident.description, incident.reporter, incident.reportDate, incident.status);
    }
}