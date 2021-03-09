var PixelToken = artifacts.require("./PixelToken.sol")

module.exports = function (deployer) {
  deployer.deploy(
    PixelToken,
    0x4606ac07453a0efa44cf5c9e17b17d909d1688d2,
    9,
    9,
    6,
    0.001
  )
}
