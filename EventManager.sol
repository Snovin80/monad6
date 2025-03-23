// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract EventManager {
    struct Event {
        string name;
        string description;
        uint256 startDate;
        uint256 endDate;
        bool isActive;
    }

    mapping(uint256 => Event) public events;
    uint256 public eventCount;

    event EventCreated(uint256 indexed eventId, string name, string description, uint256 startDate, uint256 endDate);
    event EventUpdated(uint256 indexed eventId, string name, string description, uint256 startDate, uint256 endDate);
    event EventCancelled(uint256 indexed eventId);

    function createEvent(string memory _name, string memory _description, uint256 _startDate, uint256 _endDate) public {
        require(_startDate < _endDate, "Start date must be before end date");
        eventCount++;
        events[eventCount] = Event({
            name: _name,
            description: _description,
            startDate: _startDate,
            endDate: _endDate,
            isActive: true
        });
        emit EventCreated(eventCount, _name, _description, _startDate, _endDate);
    }

    function updateEvent(uint256 _eventId, string memory _name, string memory _description, uint256 _startDate, uint256 _endDate) public {
        require(events[_eventId].isActive, "Event is not active");
        require(_startDate < _endDate, "Start date must be before end date");
        events[_eventId] = Event({
            name: _name,
            description: _description,
            startDate: _startDate,
            endDate: _endDate,
            isActive: true
        });
        emit EventUpdated(_eventId, _name, _description, _startDate, _endDate);
    }

    function cancelEvent(uint256 _eventId) public {
        require(events[_eventId].isActive, "Event is not active");
        events[_eventId].isActive = false;
        emit EventCancelled(_eventId);
    }

    function getEvent(uint256 _eventId) public view returns (string memory name, string memory description, uint256 startDate, uint256 endDate, bool isActive) {
        Event memory eventInfo = events[_eventId];
        return (eventInfo.name, eventInfo.description, eventInfo.startDate, eventInfo.endDate, eventInfo.isActive);
    }
}