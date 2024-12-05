import { config as dotenvConfig } from "dotenv";
dotenvConfig();

import { NetworkUserConfig } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import "@typechain/hardhat";

const chainIds = {
  mainnet: 1,
  goerli: 5,
  sepolia: 11155111,
  hardhat: 31337,
};

let privateKey: string;
if (!process.env.PRIVATE_KEY) {
  throw new Error("Please set your MNEMONIC in a .env file");
} else {
  privateKey = process.env.PRIVATE_KEY;
}

let infuraApiKey: string;
if (!process.env.INFURA_API_KEY) {
  throw new Error("Please set your INFURA_API_KEY in a .env file");
} else {
  infuraApiKey = process.env.INFURA_API_KEY;
}

function createNetworkConfig(
  network: keyof typeof chainIds,
): NetworkUserConfig {
  const url: string = `https://${network}.infura.io/v3/${infuraApiKey}`;
  return {
    accounts: [privateKey],
    chainId: chainIds[network],
    gas: "auto",
    gasPrice: "auto",
    url,
  };
}

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      // accounts: [privateKey],
      // chainId: chainIds.hardhat,
    },
    mainnet: createNetworkConfig("mainnet"),
    sepolia: createNetworkConfig("sepolia"),
  },

  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY,
      sepolia: process.env.ETHERSCAN_API_KEY,
    },
  },

  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
  },

  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
    overrides: {},
  },
};
