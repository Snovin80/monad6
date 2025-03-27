// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract EventTicketing {
    struct Ticket {
        string eventName;
        uint256 ticketId;
        address owner;
        bool used;
    }

    mapping(uint256 => Ticket) public tickets;
    uint256 public ticketCount;

    event TicketIssued(uint256 indexed ticketId, string eventName, address owner);
    event TicketUsed(uint256 indexed ticketId);

    function issueTicket(string memory _eventName) public {
        ticketCount++;
        tickets[ticketCount] = Ticket({
            eventName: _eventName,
            ticketId: ticketCount,
            owner: msg.sender,
            used: false
        });
        emit TicketIssued(ticketCount, _eventName, msg.sender);
    }

    function useTicket(uint256 _ticketId) public {
        Ticket storage ticket = tickets[_ticketId];
        require(ticket.owner == msg.sender, "Not ticket owner");
        require(!ticket.used, "Ticket already used");
        ticket.used = true;
        emit TicketUsed(_ticketId);
    }

    function getTicket(uint256 _ticketId) public view returns (string memory eventName, uint256 ticketId, address owner, bool used) {
        Ticket memory ticket = tickets[_ticketId];
        return (ticket.eventName, ticket.ticketId, ticket.owner, ticket.used);
    }
}