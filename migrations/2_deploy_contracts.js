var PixelToken = artifacts.require("./ExhibitToken.sol")

module.exports = function (deployer) {
    deployer.deploy(
      PixelToken,
      "0x4606Ac07453a0eFa44cf5C9e17b17D909d1688D2",
      50,
      6000,
    )
}
