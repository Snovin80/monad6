// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract EmployeeReviewSystem {
    struct Review {
        address employee;
        string reviewer;
        string comments;
        uint256 rating;
        uint256 reviewDate;
    }

    mapping(address => Review[]) public reviews;

    event ReviewSubmitted(address indexed employee, string reviewer, string comments, uint256 rating);

    function submitReview(address _employee, string memory _reviewer, string memory _comments, uint256 _rating) public {
        require(_rating >= 0 && _rating <= 10, "Rating must be between 0 and 10");
        reviews[_employee].push(Review({
            employee: _employee,
            reviewer: _reviewer,
            comments: _comments,
            rating: _rating,
            reviewDate: block.timestamp
        }));
        emit ReviewSubmitted(_employee, _reviewer, _comments, _rating);
    }

    function getReviews(address _employee) public view returns (Review[] memory) {
        return reviews[_employee];
    }
}