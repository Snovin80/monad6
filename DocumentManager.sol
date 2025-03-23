// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract DocumentManager {
    struct Document {
        string title;
        string contentHash;
        uint256 timestamp;
        bool verified;
    }

    mapping(uint256 => Document) public documents;
    uint256 public documentCount;

    event DocumentAdded(uint256 indexed documentId, string title, string contentHash, uint256 timestamp);
    event DocumentVerified(uint256 indexed documentId);

    function addDocument(string memory _title, string memory _contentHash) public {
        documentCount++;
        documents[documentCount] = Document({
            title: _title,
            contentHash: _contentHash,
            timestamp: block.timestamp,
            verified: false
        });
        emit DocumentAdded(documentCount, _title, _contentHash, block.timestamp);
    }

    function verifyDocument(uint256 _documentId) public {
        require(!documents[_documentId].verified, "Document already verified");
        documents[_documentId].verified = true;
        emit DocumentVerified(_documentId);
    }

    function getDocument(uint256 _documentId) public view returns (string memory title, string memory contentHash, uint256 timestamp, bool verified) {
        Document memory document = documents[_documentId];
        return (document.title, document.contentHash, document.timestamp, document.verified);
    }
}