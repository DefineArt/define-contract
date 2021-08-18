var DFA721NFT = artifacts.require("./DFA721NFT.sol");
var EnglishAuctionNFT = artifacts.require("./EnglishAuctionNFT.sol");
var FixedSwapNFT = artifacts.require("./FixedSwapNFT.sol");
var NFTIndexer = artifacts.require("./NFTIndexer.sol");

// const governer = ''
// const trxFeeTo = ''

module.exports = async function(deployer) {
  await deployer.deploy(DFA721NFT, 'DeFine Art', 'DFA', 'https://define.one');

  await deployer.deploy(EnglishAuctionNFT);
  await deployer.deploy(FixedSwapNFT)
  await deployer.deploy(NFTIndexer)

  await EnglishAuctionNFT.deployed().then(instance => {
    return instance.initialize(governer)
  })

  await FixedSwapNFT.deployed().then(instance => {
    return instance.initialize(governer)
  })

  await NFTIndexer.deployed().then(instance => {
    return instance.initialize(governer)
  })
  
  //--
  await NFTIndexer.deployed().then(instance => {
    return instance.setAuction(EnglishAuctionNFT.address)
  })

  await NFTIndexer.deployed().then(instance => {
    return instance.setFixswap(FixedSwapNFT.address)
  })

  //--
  await EnglishAuctionNFT.deployed().then(instance => {
    return instance.setIndexer(NFTIndexer.address)
  })

  await FixedSwapNFT.deployed().then(instance => {
    return instance.setIndexer(NFTIndexer.address)
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
