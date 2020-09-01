const { projectId, mnemonic } = require('./secrets.json');
const HDWalletProvider = require('@truffle/hdwallet-provider');


module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!

  compilers: {
    solc: {
      version: "0.6.2"
    }
  },

  plugins: [
    'truffle-plugin-verify'
  ],

  api_keys: {
    etherscan: '0000000000000000000000000000000000'
  },

  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      gas:6721975,
      network_id: "*" // Match any network id
    },

    mainnet: {
      provider: () => new HDWalletProvider("**************",
                                        "https://mainnet.infura.io/v3/ffffffffffffffffffffffffffffffff"),
      network_id: 1,
      gasPrice: 5*10e9
    },

    rinkeby: {
      networkCheckTimeout:100000,
      provider: () => new HDWalletProvider(
        mnemonic, `https://rinkeby.infura.io/v3/ffffffffffffffffffffffffffffffff`
      ),
      network_id: 4,

      gas:6721975,
      gasPrice: 10e9
    }
  }
};
