// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract KnowledgeBase {
    struct Article {
        string title;
        string content;
        address author;
        uint256 version;
        uint256 timestamp;
        bool active;
        mapping(address => bool) accessRights;
    }

    mapping(uint256 => Article) public articles;
    uint256 public articleCount;

    address public owner;

    event ArticleAdded(uint256 indexed articleId, string title, address author);
    event ArticleUpdated(uint256 indexed articleId, string newContent, address updater);
    event AccessGranted(uint256 indexed articleId, address indexed user);
    event AccessRevoked(uint256 indexed articleId, address indexed user);
    event ArticleDeactivated(uint256 indexed articleId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyOwnerOrUser(uint256 _articleId) {
        require(msg.sender == owner || articles[_articleId].accessRights[msg.sender], "Access denied");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addArticle(string memory _title, string memory _content) public onlyOwner {
        articleCount++;
        Article storage newArticle = articles[articleCount];
        newArticle.title = _title;
        newArticle.content = _content;
        newArticle.author = msg.sender;
        newArticle.version = 1;
        newArticle.timestamp = block.timestamp;
        newArticle.active = true;
        newArticle.accessRights[msg.sender] = true;
        emit ArticleAdded(articleCount, _title, msg.sender);
    }

    function updateArticle(uint256 _articleId, string memory _newContent) public onlyOwnerOrUser(_articleId) {
        Article storage article = articles[_articleId];
        require(article.active, "Article is deactivated");
        article.version++;
        article.content = _newContent;
        article.timestamp = block.timestamp;
        emit ArticleUpdated(_articleId, _newContent, msg.sender);
    }

    function grantAccess(uint256 _articleId, address _user) public onlyOwner {
        Article storage article = articles[_articleId];
        require(article.active, "Article is deactivated");
        article.accessRights[_user] = true;
        emit AccessGranted(_articleId, _user);
    }

    function revokeAccess(uint256 _articleId, address _user) public onlyOwner {
        Article storage article = articles[_articleId];
        require(article.active, "Article is deactivated");
        article.accessRights[_user] = false;
        emit AccessRevoked(_articleId, _user);
    }

    function deactivateArticle(uint256 _articleId) public onlyOwner {
        Article storage article = articles[_articleId];
        require(article.active, "Article is already deactivated");
        article.active = false;
        emit ArticleDeactivated(_articleId);
    }

    function getArticle(uint256 _articleId) public view onlyOwnerOrUser(_articleId) returns (
        string memory title,
        string memory content,
        address author,
        uint256 version,
        uint256 timestamp,
        bool active
    ) {
        Article storage article = articles[_articleId];
        return (article.title, article.content, article.author, article.version, article.timestamp, article.active);
    }

    function hasAccess(uint256 _articleId, address _user) public view returns (bool) {
        return articles[_articleId].accessRights[_user];
    }
}