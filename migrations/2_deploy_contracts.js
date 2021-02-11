var SimpleStorage = artifacts.require("./SimpleStorage.sol")
var America = artifacts.require("./America.sol")

module.exports = function (deployer) {
  deployer.deploy(SimpleStorage)
}
