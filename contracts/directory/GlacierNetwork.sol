// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GlacierNetwork is Ownable {
    using SafeMath for uint256;

    struct User {
        uint256 balance; // User balance in native currency (e.g., ETH)
        uint256 lastWithdrawalTime; // Last withdrawal time (for businesses)
        uint256 withdrawalRequest; // Pending withdrawal request (for businesses)
        bool isBusiness; // Whether the user is a business
        bool isWithdrawalApproved; // Whether the business' withdrawal is approved
    }

    mapping(address => User) public users;
    mapping(address => mapping(address => uint256)) public userTokenBalances; // token -> balance mapping

    uint256 constant WITHDRAWAL_LIMIT = 100 * 10**18;  // $100 limit (adjust based on token decimals)
    uint256 constant BUSINESS_WITHDRAWAL_INTERVAL = 30 days; // Business withdrawal interval (1 month)
    uint256 constant STAKING_LOCK_TIME = 15 * 365 days; // 15 years lock time for staking

    // Glacier Treasury (Digital Mortgage)
    address public glacierTreasury;
    uint256 public totalProfitsStaked;

    // Event declarations
    event WithdrawalRequested(address indexed user, uint256 amount);
    event WithdrawalApproved(address indexed user, uint256 amount);
    event WithdrawalRejected(address indexed user);
    event ProfitsStaked(address indexed user, uint256 amount);

    // Modifier for business verification
    modifier onlyBusiness() {
        require(users[msg.sender].isBusiness, "Only businesses can call this");
        _;
    }

    // Modifier for checking withdrawal approval status
    modifier onlyApprovedWithdrawal() {
        require(users[msg.sender].isWithdrawalApproved, "Withdrawal not approved");
        _;
    }

    // Set the Glacier Treasury address (admin function)
    function setGlacierTreasury(address treasury) public onlyOwner {
        glacierTreasury = treasury;
    }

    // Set user as business (admin function)
    function setBusinessStatus(address user, bool isBusiness) public onlyOwner {
        users[user].isBusiness = isBusiness;
    }

    // Deposit function that includes staking profits (only 10% of 20% goes to the Treasury)
    function deposit(address token, uint256 amount) public {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        userTokenBalances[msg.sender][token] += amount;
        
        uint256 profitShare = amount.mul(20).div(100); // 20% of the profit goes to user/business
        uint256 treasuryStake = profitShare.mul(10).div(100); // 10% of that 20% goes to Glacier Treasury

        _stakeProfits(treasuryStake);  // Stake the 10% of 20% into the treasury
    }

    // Function that stakes 10% of the 20% profit share into the Glacier Treasury
    function _stakeProfits(uint256 amount) internal {
        userTokenBalances[glacierTreasury][msg.sender] += amount;
        totalProfitsStaked = totalProfitsStaked.add(amount);

        // Emitting the event
        emit ProfitsStaked(msg.sender, amount);
    }

    // Request withdrawal (for both businesses and regular users)
    function requestWithdrawal(uint256 amount, address token) public {
        User storage user = users[msg.sender];
        require(user.balance >= amount, "Insufficient balance");

        // Check for businesses to ensure monthly limit
        if (user.isBusiness) {
            require(block.timestamp > user.lastWithdrawalTime + BUSINESS_WITHDRAWAL_INTERVAL, "Can only withdraw once per month");
            user.withdrawalRequest = amount;
            emit WithdrawalRequested(msg.sender, amount);
        } else {
            require(amount <= WITHDRAWAL_LIMIT, "Cannot withdraw more than $100");
            user.balance -= amount;
            IERC20(token).transfer(msg.sender, amount);
        }
    }

    // Approve or reject business withdrawal (admin function)
    function approveWithdrawal(address business) public onlyOwner {
        User storage user = users[business];
        require(user.isBusiness, "Not a business user");
        require(user.withdrawalRequest > 0, "No withdrawal requested");

        // Approve and transfer the amount
        user.isWithdrawalApproved = true;
        user.lastWithdrawalTime = block.timestamp;  // Set last withdrawal time for the business
        uint256 amount = user.withdrawalRequest;
        user.balance -= amount;

        // Transfer the requested amount (can be in multiple tokens)
        emit WithdrawalApproved(business, amount);
    }

    // Reject business withdrawal (admin function)
    function rejectWithdrawal(address business) public onlyOwner {
        User storage user = users[business];
        require(user.isBusiness, "Not a business user");
        require(user.withdrawalRequest > 0, "No withdrawal requested");

        user.isWithdrawalApproved = false;
        emit WithdrawalRejected(business);
    }

    // Function to withdraw any ERC20 token
    function withdrawTokens(address token, uint256 amount) public {
        require(userTokenBalances[msg.sender][token] >= amount, "Insufficient token balance");
        userTokenBalances[msg.sender][token] -= amount;
        IERC20(token).transfer(msg.sender, amount);
    }

    // Function to get user balance for a specific token
    function getUserTokenBalance(address user, address token) public view returns (uint256) {
        return userTokenBalances[user][token];
    }

    // Function to get the user balance in the native currency (ETH)
    function getUserBalance(address user) public view returns (uint256) {
        return users[user].balance;
    }

    // Function to get the total profits staked in Glacier Treasury
    function getTotalProfitsStaked() public view returns (uint256) {
        return totalProfitsStaked;
    }

    // Function to get the lock expiry time for Glacier Treasury
    function getLockExpiryTime() public view returns (uint256) {
        return block.timestamp + STAKING_LOCK_TIME;
    }
}