// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract CertificateManager {
    struct Certificate {
        string name;
        string description;
        uint256 issueDate;
        bool revoked;
    }

    mapping(uint256 => Certificate) public certificates;
    uint256 public certificateCount;

    event CertificateIssued(uint256 indexed certificateId, string name, string description, uint256 issueDate);
    event CertificateRevoked(uint256 indexed certificateId);

    function issueCertificate(string memory _name, string memory _description) public {
        certificateCount++;
        certificates[certificateCount] = Certificate({
            name: _name,
            description: _description,
            issueDate: block.timestamp,
            revoked: false
        });
        emit CertificateIssued(certificateCount, _name, _description, block.timestamp);
    }

    function revokeCertificate(uint256 _certificateId) public {
        require(!certificates[_certificateId].revoked, "Certificate already revoked");
        certificates[_certificateId].revoked = true;
        emit CertificateRevoked(_certificateId);
    }

    function getCertificate(uint256 _certificateId) public view returns (string memory name, string memory description, uint256 issueDate, bool revoked) {
        Certificate memory certificate = certificates[_certificateId];
        return (certificate.name, certificate.description, certificate.issueDate, certificate.revoked);
    }
}