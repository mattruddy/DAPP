const path = require("path");

module.exports = {
  compilers: {
    solc: {
      version: "0.6.2",
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
  },
};
