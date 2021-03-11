const path = require("path")
const HDWalletProvider = require("@truffle/hdwallet-provider")

module.exports = {
  compilers: {
    solc: {
      version: "0.7.4",
    },
  },
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: path.join(
    __dirname,
    "../crypto-canvas-fe/contracts"
  ),
  networks: {
    develop: {
      port: 8545,
    },
    ropsten: {
      provider: () => {
        return new HDWalletProvider(
          "deputy broom lawsuit hire destroy demise pelican inhale shrimp scene bitter rib",
          "https://ropsten.infura.io/v3/60420780afe54f0c9916f68730909f78",
          1
        )
      },
      network_id: "3",
    },
    rinkeby: {
      provider: () => {
        return new HDWalletProvider(
          "deputy broom lawsuit hire destroy demise pelican inhale shrimp scene bitter rib",
          "https://rinkeby.infura.io/v3/60420780afe54f0c9916f68730909f78",
          1
        )
      },
      network_id: "4",
    },
  },
}
