// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract DocumentManagement {
    struct Document {
        string title;
        string contentHash;
        uint256 version;
        address docOwner;
        uint256 timestamp;
        bool active;
        mapping(address => bool) accessRights;
    }

    mapping(uint256 => Document) public documents;
    uint256 public documentCount;

    address public owner;

    event DocumentAdded(uint256 indexed documentId, string title, string contentHash, address owner);
    event DocumentUpdated(uint256 indexed documentId, string newContentHash, address updater);
    event AccessGranted(uint256 indexed documentId, address indexed user);
    event AccessRevoked(uint256 indexed documentId, address indexed user);
    event DocumentDeactivated(uint256 indexed documentId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyOwnerOrUser(uint256 _documentId) {
        require(msg.sender == owner || documents[_documentId].accessRights[msg.sender], "Access denied");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addDocument(string memory _title, string memory _contentHash) public onlyOwner {
        documentCount++;
        Document storage newDocument = documents[documentCount];
        newDocument.title = _title;
        newDocument.contentHash = _contentHash;
        newDocument.version = 1;
        newDocument.docOwner = msg.sender;
        newDocument.timestamp = block.timestamp;
        newDocument.active = true;
        newDocument.accessRights[msg.sender] = true;
        emit DocumentAdded(documentCount, _title, _contentHash, msg.sender);
    }

    function updateDocument(uint256 _documentId, string memory _newContentHash) public onlyOwnerOrUser(_documentId) {
        Document storage document = documents[_documentId];
        require(document.active, "Document is deactivated");
        document.version++;
        document.contentHash = _newContentHash;
        document.timestamp = block.timestamp;
        emit DocumentUpdated(_documentId, _newContentHash, msg.sender);
    }

    function grantAccess(uint256 _documentId, address _user) public onlyOwner {
        Document storage document = documents[_documentId];
        require(document.active, "Document is deactivated");
        document.accessRights[_user] = true;
        emit AccessGranted(_documentId, _user);
    }

    function revokeAccess(uint256 _documentId, address _user) public onlyOwner {
        Document storage document = documents[_documentId];
        require(document.active, "Document is deactivated");
        document.accessRights[_user] = false;
        emit AccessRevoked(_documentId, _user);
    }

    function deactivateDocument(uint256 _documentId) public onlyOwner {
        Document storage document = documents[_documentId];
        require(document.active, "Document is already deactivated");
        document.active = false;
        emit DocumentDeactivated(_documentId);
    }

    function getDocument(uint256 _documentId) public view onlyOwnerOrUser(_documentId) returns (
        string memory title,
        string memory contentHash,
        uint256 version,
        address owner,
        uint256 timestamp,
        bool active
    ) {
        Document storage document = documents[_documentId];
        return (document.title, document.contentHash, document.version, document.docOwner, document.timestamp, document.active);
    }

    function hasAccess(uint256 _documentId, address _user) public view returns (bool) {
        return documents[_documentId].accessRights[_user];
    }
}