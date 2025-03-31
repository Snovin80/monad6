// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract EventManager {
    struct Event {
        string name;
        uint256 date;
    }

    mapping(uint256 => Event) public events;
    uint256 public eventId;

    event EventCreated(uint256 indexed id, string name, uint256 date);

    function createEvent(string memory _name, uint256 _date) public {
        eventId++;
        events[eventId] = Event(_name, _date);
        emit EventCreated(eventId, _name, _date);
    }

    function getEvent(uint256 _id) public view returns (string memory, uint256) {
        return (events[_id].name, events[_id].date);
    }
}