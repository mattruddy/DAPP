var PixelToken = artifacts.require("./PixelToken.sol")

module.exports = function (deployer) {
  deployer.deploy(
    PixelToken,
    "0x4606Ac07453a0eFa44cf5C9e17b17D909d1688D2",
    9,
    6000,
    100000
  )
}
