// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract ContentModeration {
    struct Content {
        string title;
        string contentHash;
        address author;
        bool approved;
        bool flagged;
    }

    Content[] public contents;

    event ContentSubmitted(uint256 indexed contentId, string title, string contentHash, address author);
    event ContentApproved(uint256 indexed contentId);
    event ContentFlagged(uint256 indexed contentId);

    function submitContent(string memory _title, string memory _contentHash) public {
        contents.push(Content({
            title: _title,
            contentHash: _contentHash,
            author: msg.sender,
            approved: false,
            flagged: false
        }));
        emit ContentSubmitted(contents.length - 1, _title, _contentHash, msg.sender);
    }

    function approveContent(uint256 _contentId) public {
        Content storage content = contents[_contentId];
        require(content.author != msg.sender, "Author cannot approve own content");
        require(!content.approved, "Content already approved");
        content.approved = true;
        emit ContentApproved(_contentId);
    }

    function flagContent(uint256 _contentId) public {
        Content storage content = contents[_contentId];
        require(content.author != msg.sender, "Author cannot flag own content");
        require(!content.flagged, "Content already flagged");
        content.flagged = true;
        emit ContentFlagged(_contentId);
    }
}