// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract AuditLog {
    struct LogEntry {
        string action;
        address actor;
        uint256 timestamp;
        string details;
    }

    LogEntry[] public logEntries;

    event LogAdded(uint256 indexed logId, string action, address actor, string details);

    function addLog(string memory _action, string memory _details) public {
        logEntries.push(LogEntry({
            action: _action,
            actor: msg.sender,
            timestamp: block.timestamp,
            details: _details
        }));
        emit LogAdded(logEntries.length - 1, _action, msg.sender, _details);
    }

    function getLog(uint256 _logId) public view returns (string memory action, address actor, uint256 timestamp, string memory details) {
        LogEntry memory logEntry = logEntries[_logId];
        return (logEntry.action, logEntry.actor, logEntry.timestamp, logEntry.details);
    }
}