/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require('@nomiclabs/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');

const { projectId, mnemonic } = require('./secret.json');

module.exports = {
    solidity:{
       version: "0.6.12",
       settings: {          
            optimizer: {
              enabled: true,
              runs: 200
            },
            evmVersion: "byzantium"
       }
    },
    networks: {
        mainnet: {
          url: `https://mainnet.infura.io/v3/${projectId}`,
          gasPrice: 50000000000,
          accounts: {mnemonic: mnemonic},
          network_id: 1,
        },
        rinkeby: {
            url: `https://rinkeby.infura.io/v3/${projectId}`,
            accounts: {mnemonic: mnemonic},
            network_id: 4
        },
        testnet: {
            url: `https://data-seed-prebsc-1-s1.binance.org:8545`,
            accounts: {mnemonic: mnemonic},
            network_id: 97
        },
        bsc: {
            url: `https://bsc-dataseed.binance.org`,
            accounts: {mnemonic: mnemonic},
            network_id: 1
        }
  },
};
