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
    networks:{
        hardhat:{
            forking:{
                url:process.env.ALCAMY_MAINNET,
                blockNumber:21274100
            }
        }
    }
};