// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract ProductRegistry {
    struct Product {
        string productName;
        string description;
        string manufacturer;
        uint256 manufactureDate;
        bool certified;
    }

    mapping(uint256 => Product) public products;
    uint256 public productCount;

    event ProductRegistered(uint256 indexed productId, string productName, string description, string manufacturer);
    event ProductCertified(uint256 indexed productId);

    function registerProduct(string memory _productName, string memory _description, string memory _manufacturer) public {
        productCount++;
        products[productCount] = Product({
            productName: _productName,
            description: _description,
            manufacturer: _manufacturer,
            manufactureDate: block.timestamp,
            certified: false
        });
        emit ProductRegistered(productCount, _productName, _description, _manufacturer);
    }

    function certifyProduct(uint256 _productId) public {
        require(!products[_productId].certified, "Product already certified");
        products[_productId].certified = true;
        emit ProductCertified(_productId);
    }

    function getProduct(uint256 _productId) public view returns (string memory productName, string memory description, string memory manufacturer, uint256 manufactureDate, bool certified) {
        Product memory product = products[_productId];
        return (product.productName, product.description, product.manufacturer, product.manufactureDate, product.certified);
    }
}