// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
address public constant GLACIER_TREASURY = 0x0607B8F6C27A206C617426EEEc0E44aF01A29d32;
uint256 public constant STAKING_LOCK_TIME = 15 * 365 days; // 15 years lock period
mapping(address => mapping(address => uint256)) public tokenDepositTime; // Store deposit timestamps
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
function distributeProfits(address user, uint256 totalProfit, address token) public onlyOwner {
    require(totalProfit > 0, "No profit to distribute");

    uint256 userShare = (totalProfit * 20) / 100; // 20% of the profit to user
    uint256 treasuryShare = (userShare * 10) / 100; // 10% of the 20% goes to Glacier Treasury
    uint256 finalUserAmount = userShare - treasuryShare; // Remaining amount for user

    // Transfer to Glacier Treasury
    userTokenBalances[GLACIER_TREASURY][token] += treasuryShare;
    tokenDepositTime[GLACIER_TREASURY][token] = block.timestamp; // Store deposit time

    // Transfer remaining amount to user
    userTokenBalances[user][token] += finalUserAmount;
}