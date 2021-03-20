var PixelToken = artifacts.require("./ExhibitToken.sol")

module.exports = function (deployer, network) {

    // OpenSea proxy registry addresses for rinkeby and mainnet.
    let proxyRegistryAddress = "";
    if (network === 'rinkeby') {
      proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
    } else if (network === 'live') {
      proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
    }
    deployer.deploy(
      PixelToken,
      "0x4606Ac07453a0eFa44cf5C9e17b17D909d1688D2",
      1000000,
      proxyRegistryAddress
    )
}
