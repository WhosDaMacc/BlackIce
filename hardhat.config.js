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