// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract CredentialIssuer {
    struct Credential {
        string credentialType;
        string issuer;
        string recipient;
        uint256 issueDate;
        bool valid;
    }

    mapping(uint256 => Credential) public credentials;
    uint256 public credentialCount;

    event CredentialIssued(uint256 indexed credentialId, string credentialType, string issuer, string recipient);
    event CredentialRevoked(uint256 indexed credentialId);

    function issueCredential(string memory _credentialType, string memory _issuer, string memory _recipient) public {
        credentialCount++;
        credentials[credentialCount] = Credential({
            credentialType: _credentialType,
            issuer: _issuer,
            recipient: _recipient,
            issueDate: block.timestamp,
            valid: true
        });
        emit CredentialIssued(credentialCount, _credentialType, _issuer, _recipient);
    }

    function revokeCredential(uint256 _credentialId) public {
        require(credentials[_credentialId].valid, "Credential already revoked");
        credentials[_credentialId].valid = false;
        emit CredentialRevoked(_credentialId);
    }

    function getCredential(uint256 _credentialId) public view returns (string memory credentialType, string memory issuer, string memory recipient, uint256 issueDate, bool valid) {
        Credential memory credential = credentials[_credentialId];
        return (credential.credentialType, credential.issuer, credential.recipient, credential.issueDate, credential.valid);
    }
}