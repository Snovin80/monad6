// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract QualityControl {
    struct Inspection {
        string productName;
        address inspector;
        string result;
        uint256 inspectionDate;
        bool passed;
    }

    mapping(uint256 => Inspection) public inspections;
    uint256 public inspectionCount;

    event InspectionPerformed(uint256 indexed inspectionId, string productName, address inspector, string result, bool passed);
    event InspectionResultUpdated(uint256 indexed inspectionId, string newResult, bool newPassed);

    function performInspection(string memory _productName, string memory _result, bool _passed) public {
        inspectionCount++;
        inspections[inspectionCount] = Inspection({
            productName: _productName,
            inspector: msg.sender,
            result: _result,
            inspectionDate: block.timestamp,
            passed: _passed
        });
        emit InspectionPerformed(inspectionCount, _productName, msg.sender, _result, _passed);
    }

    function updateInspectionResult(uint256 _inspectionId, string memory _newResult, bool _newPassed) public {
        Inspection storage inspection = inspections[_inspectionId];
        require(inspection.inspector == msg.sender, "Not inspection inspector");
        inspection.result = _newResult;
        inspection.passed = _newPassed;
        emit InspectionResultUpdated(_inspectionId, _newResult, _newPassed);
    }

    function getInspection(uint256 _inspectionId) public view returns (string memory productName, address inspector, string memory result, uint256 inspectionDate, bool passed) {
        Inspection memory inspection = inspections[_inspectionId];
        return (inspection.productName, inspection.inspector, inspection.result, inspection.inspectionDate, inspection.passed);
    }
}