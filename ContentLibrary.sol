// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract ContentLibrary {
    struct Content {
        string title;
        string contentHash;
        address author;
        uint256 uploadDate;
        bool active;
    }

    mapping(uint256 => Content) public contents;
    uint256 public contentCount;

    event ContentUploaded(uint256 indexed contentId, string title, string contentHash, address author);
    event ContentDeactivated(uint256 indexed contentId);

    function uploadContent(string memory _title, string memory _contentHash) public {
        contentCount++;
        contents[contentCount] = Content({
            title: _title,
            contentHash: _contentHash,
            author: msg.sender,
            uploadDate: block.timestamp,
            active: true
        });
        emit ContentUploaded(contentCount, _title, _contentHash, msg.sender);
    }

    function deactivateContent(uint256 _contentId) public {
        Content storage content = contents[_contentId];
        require(content.author == msg.sender, "Not content author");
        require(content.active, "Content already deactivated");
        content.active = false;
        emit ContentDeactivated(_contentId);
    }

    function getContent(uint256 _contentId) public view returns (string memory title, string memory contentHash, address author, uint256 uploadDate, bool active) {
        Content memory content = contents[_contentId];
        return (content.title, content.contentHash, content.author, content.uploadDate, content.active);
    }
}