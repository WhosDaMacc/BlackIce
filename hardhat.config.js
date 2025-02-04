require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: "0.8.0",
  networks: {
    polygon: {
      url: `https://polygon-rpc.com`,  // Polygon RPC URL
      accounts: [`0x${YOUR_PRIVATE_KEY}`], // Replace with your private key
    },
  },
};
require('@nomiclabs/hardhat-ethers');
require("dotenv").config();

module.exports = {
  solidity: "0.8.0",
  networks: {
    polygon: {
      url: process.env.POLYGON_URL,  // QuickNode URL
      accounts: [`0x${process.env.PRIVATE_KEY}`],  // Private key for deployment
    },
  },
};
require('@nomiclabs/hardhat-ethers');
require("dotenv").config();

module.exports = {
  solidity: "0.8.0",
  networks: {
    polygon: {
      url: process.env.POLYGON_URL,  // QuickNode URL
      accounts: [`0x${process.env.PRIVATE_KEY}`],  // Private key for deployment
    },
  },
};
require('@nomiclabs/hardhat-etherscan');

module.exports = {
  solidity: "0.8.0",  // or whatever version of Solidity you're using
  networks: {
    // configure networks like Polygon here
  },
  etherscan: {
    apiKey: "YOUR_ETHERSCAN_API_KEY"  // Replace with your Etherscan API key
  }
};
