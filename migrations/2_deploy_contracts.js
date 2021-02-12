var PixelToken = artifacts.require("./PixelToken.sol")

module.exports = function (deployer) {
  deployer.deploy(PixelToken)
}
