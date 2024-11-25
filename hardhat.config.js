require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        compilers: [{
                version: "0.8.10"
            },
            {
                version: "0.8.20"
            },
            {
                version: "0.7.0"
            },
            {
                version: "0.7.5"
            },
            {
                version: "0.8.0"
            }
        ]
    },
    networks: {
        sepolia: {
            url: process.env.INFURA_SEPOLIA_ENDPOINT,
            accounts: [process.env.PRIVATE_KEY],
        },
        goerli: {
            url: process.env.INFURA_GOERLI_ENDPOINT,
            accounts: [process.env.PRIVATE_KEY],
        },
        mainnet: {
            url: process.env.INFURA_MAINNET_ENDPOINT,
            accounts: [process.env.PRIVATE_KEY]
        },
        mumbai: {
          url: process.env.MUMBAI,
          accounts: [process.env.PRIVATE_KEY]
      },
    },
};