import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import './App.css';

function App() {
  const [walletAddress, setWalletAddress] = useState('');
  const [userBalance, setUserBalance] = useState(0);
  const [statusText, setStatusText] = useState('');
  const [statusUpdates, setStatusUpdates] = useState([]);
  
  const contractAddress = process.env.REACT_APP_CONTRACT_ADDRESS;
  const contractABI = process.env.REACT_APP_CONTRACT_ABI;
  
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const contract = new ethers.Contract(contractAddress, contractABI, provider);

  // Connect MetaMask wallet
  const connectWallet = async () => {
    if (window.ethereum) {
      await provider.send("eth_requestAccounts", []);
      setWalletAddress(await provider.getSigner().getAddress());
    }
  };

  // Check balance and update state
  useEffect(() => {
    if (walletAddress) {
      const fetchBalance = async () => {
        const balance = await contract.balanceOf(walletAddress);
        setUserBalance(ethers.utils.formatEther(balance));
      };
      fetchBalance();
    }
  }, [walletAddress]);

  // Handle withdrawal logic
  const handleWithdraw = async () => {
    if (userBalance >= 100) {
      await contract.withdraw(ethers.utils.parseEther('100'), walletAddress);
      alert('Withdrawal successful!');
    } else {
      alert('Insufficient balance to withdraw $100.');
    }
  };

  // Post status updates
  const postStatus = () => {
    if (!statusText.trim()) return;
    // Emit event to backend (through socket or API)
    setStatusUpdates(prev => [{ text: statusText, timestamp: new Date() }, ...prev]);
    setStatusText('');
  };

  return (
    <div className="container">
      {!walletAddress ? (
        <button onClick={connectWallet}>Connect Wallet</button>
      ) : (
        <p>{walletAddress.slice(0, 6)}...{walletAddress.slice(-4)}</p>
      )}
      
      <div className="balance">
        <p>Balance: {userBalance} Tokens</p>
        <button onClick={handleWithdraw}>Withdraw $100</button>
      </div>

      <div className="status-section">
        <h3>Status Feed</h3>
        <textarea
          value={statusText}
          onChange={(e) => setStatusText(e.target.value)}
          placeholder="Post a status..."
        />
        <button onClick={postStatus}>Post</button>
        {statusUpdates.map((status, index) => (
          <div key={index}>
            <p>{status.text}</p>
            <small>{status.timestamp.toLocaleString()}</small>
          </div>
        ))}
      </div>
    </div>
  );
}

export default App;
const contractAddress = process.env.REACT_APP_CONTRACT_ADDRESS;
const contractABI = JSON.parse(process.env.REACT_APP_CONTRACT_ABI);