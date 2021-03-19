var PixelToken = artifacts.require("./ExhibitToken.sol")
var Auction = artifacts.require("./Auction.sol")

module.exports = function (deployer) {
  deployer.deploy(Auction).then(() => {
    return deployer.deploy(
      PixelToken,
      "0x4606Ac07453a0eFa44cf5C9e17b17D909d1688D2",
      50,
      6000,
      100000,
      Auction.address
    )
  })
}
