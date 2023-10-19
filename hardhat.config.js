require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.9",
  networks: {
    sepolia: { // Add Sepolia network configuration
      url: "https://sepolia.infura.io/v3/ed0543ded12947a5aa73445d0a646141", // Replace with your Infura Project ID
      accounts: ["45a990dc3e33af3d3bdaa3e86878f141ceef52725c239e9a87382244755aaf72"],
    },
  },
  paths: {
    artifacts: "./client/src/artifacts",
  },
};
