// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GlacierNetwork {
    mapping(address => uint256) public balances;
    address public owner;
    uint256 public lastWithdrawal;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute this");
        _;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient funds");
        require(amount == 100 ether, "Can only withdraw $100 worth at a time");
        payable(msg.sender).transfer(amount);
        balances[msg.sender] -= amount;
        lastWithdrawal = block.timestamp;
    }

    function getBalance(address user) public view returns (uint256) {
        return balances[user];
    }
}