//var DFA721NFT = artifacts.require("./DFA721NFT.sol");
var EnglishAuctionNFT = artifacts.require("./EnglishAuctionNFT.sol");
var FixedSwapNFT = artifacts.require("./FixedSwapNFT.sol");
// var NFTIndexer = artifacts.require("./NFTIndexer.sol");
// var ProxyAdmin = artifacts.require("./ProxyAdmin.sol");
// var AdminUpgradeabilityProxy = artifacts.require("./AdminUpgradeabilityProxy.sol");

const governer = ''
const trxFeeTo = ''

module.exports = async function(deployer) {
  await deployer.deploy(FixedSwapNFT);
  //await deployer.deploy(ProxyAdmin);
  //await deployer.deploy(AdminUpgradeabilityProxy, 'TYCgov3GSZUfu1NRbes43TRun1N8URXvZx', 'TDPsTdA1Fvv5kfbjzvNjabM3wGqF8P5bDm', '0x8129fc1c');
  //await deployer.deploy(DFA721NFT, 'DeFine Art', 'DFA', 'https://staging-api.de-fine.art/api');

  await deployer.deploy(EnglishAuctionNFT);
  // await deployer.deploy(FixedSwapNFT)
  // await deployer.deploy(NFTIndexer)

  await EnglishAuctionNFT.deployed().then(instance => {
    return instance.initialize(governer)
  })

  await FixedSwapNFT.deployed().then(instance => {
    return instance.initialize(governer)
  })

  // await NFTIndexer.deployed().then(instance => {
  //   return instance.initialize(governer)
  // })
  
  //--
  // await NFTIndexer.deployed().then(instance => {
  //   return instance.setAuction(EnglishAuctionNFT.address)
  // })

  // await NFTIndexer.deployed().then(instance => {
  //   return instance.setFixswap(FixedSwapNFT.address)
  // })

  //--
  await EnglishAuctionNFT.deployed().then(instance => {
    return instance.setIndexer('TLwt2jx6V8J9zFB5EvkqE8LAgXqSvwKvYX')
  })

  await FixedSwapNFT.deployed().then(instance => {
    return instance.setIndexer('TLwt2jx6V8J9zFB5EvkqE8LAgXqSvwKvYX')
  })

  //--

  await FixedSwapNFT.deployed().then(instance => {
    return instance.setFee(1000)
  })

  await FixedSwapNFT.deployed().then(instance => {
    return instance.setFeeMax(10000)
  })

  await FixedSwapNFT.deployed().then(instance => {
    return instance.setFeeTo(trxFeeTo)
  })

  await EnglishAuctionNFT.deployed().then(instance => {
    return instance.setFee(1000)
  })

  await EnglishAuctionNFT.deployed().then(instance => {
    return instance.setFeeMax(10000)
  })

  await EnglishAuctionNFT.deployed().then(instance => {
    return instance.setFeeTo(trxFeeTo)
  })

};
