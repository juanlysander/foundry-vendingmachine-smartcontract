// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract VendingMachine {
    struct Product {
        string productName;
        uint32 productStock;
        uint128 productPrice;
    }

    Product private product;
    Product[] public arrProducts;

    address private owner;
    bool locked;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can access this function");
        _;
    }

    modifier noReentrant() {
        require(!locked, "No Re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    fallback() external payable {}

    function addItemToArray(
        string memory _productName,
        uint32 _productStock,
        uint128 _productPrice
    ) public onlyOwner {
        product = Product(_productName, _productStock, _productPrice);
        arrProducts.push(product);
    }

    function buyProduct(
        uint256 _indexProduct,
        uint32 _quantity
    ) public payable returns (string memory) {
        require(_indexProduct < arrProducts.length, "Invalid product index");
        require(
            _quantity <= arrProducts[_indexProduct].productStock,
            "Not enough stock to fulfill your request"
        );
        require(
            msg.value >= arrProducts[_indexProduct].productPrice * _quantity,
            "Insufficient funds"
        );

        arrProducts[_indexProduct].productStock -= _quantity;

        if (msg.value == arrProducts[_indexProduct].productPrice * _quantity) {
            return "Transaction Successfull, please take your product";
        } else {
            payable(msg.sender).transfer(
                msg.value - arrProducts[_indexProduct].productPrice * _quantity
            );
            return
                "Transaction Successfull, please take your product & your changes";
        }
    }

    function getContractBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function withdrawVendingMachine(
        uint256 _quantity
    ) public payable onlyOwner noReentrant {
        require(
            address(this).balance >= _quantity,
            "Not enough funds to withdraw"
        );
        payable(owner).transfer(_quantity);
    }
}
