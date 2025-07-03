// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

contract AchievementCertification {
    struct Certificate {
        string achievement;
        string metadata;
        uint256 issuedDate;
        address issuer;
    }

    mapping(string => Certificate) public certificates;

    event CertificateIssued(string certificateId, string achievement, string metadata, uint256 issuedDate, address issuer);

    function issueCertificate(string memory _id, string memory _achievement, string memory _metadata) public {
        require(bytes(certificates[_id].achievement).length == 0, "Certificate already issued");
        certificates[_id] = Certificate(_achievement, _metadata, block.timestamp, msg.sender);
        emit CertificateIssued(_id, _achievement, _metadata, block.timestamp, msg.sender);
    }

    function getCertificate(string memory _id) public view returns (string memory, string memory, uint256, address) {
        require(bytes(certificates[_id].achievement).length != 0, "Certificate not issued");
        Certificate memory cert = certificates[_id];
        return (cert.achievement, cert.metadata, cert.issuedDate, cert.issuer);
    }
}