// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract KnowledgeBase {
    struct Article {
        string title;
        string content;
        address author;
        uint256 timestamp;
    }

    Article[] public articles;

    event ArticleAdded(uint256 indexed articleId, string title, address author);
    event ArticleUpdated(uint256 indexed articleId, string newContent, address updater);

    function addArticle(string memory _title, string memory _content) public {
        articles.push(Article({
            title: _title,
            content: _content,
            author: msg.sender,
            timestamp: block.timestamp
        }));
        emit ArticleAdded(articles.length - 1, _title, msg.sender);
    }

    function updateArticle(uint256 _articleId, string memory _newContent) public {
        Article storage article = articles[_articleId];
        require(article.author == msg.sender, "Only author can update article");
        article.content = _newContent;
        article.timestamp = block.timestamp;
        emit ArticleUpdated(_articleId, _newContent, msg.sender);
    }

    function getArticle(uint256 _articleId) public view returns (string memory title, string memory content, address author, uint256 timestamp) {
        Article memory article = articles[_articleId];
        return (article.title, article.content, article.author, article.timestamp);
    }
}