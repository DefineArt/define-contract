async function main() {
  const { provider, BigNumber, utils } = ethers;
  const ETH = utils.parseEther('1');
  const accounts = await ethers.provider.listAccounts()
  console.log('owner address', accounts[0])
  const EnglishAuctionNFT = await ethers.getContractFactory("EnglishAuctionNFT");
  const FixedSwapNFT = await ethers.getContractFactory("FixedSwapNFT");
  const DFA721NFT = await ethers.getContractFactory("DFA721NFT");
  const DFA1155NFT = await ethers.getContractFactory("DFA1155NFT");
  const NFTIndexer = await ethers.getContractFactory("NFTIndexer");

  const dfa721 = await DFA721NFT.deploy("d", "d", "staging-api.de-fine.art/api/tokens/")
  console.log('DFA721 ADDRESS:', dfa721.address)
  const dfa1155 = await DFA1155NFT.deploy("d", "d", "staging-api.de-fine.art/api/tokens/")
  console.log('DFA1155 ADDRESS:', dfa1155.address)
  const auction = await upgrades.deployProxy(EnglishAuctionNFT, [accounts[0]], {initializer: "initialize"})
  console.log('English Auction address:', auction.address)
  const fixswap = await upgrades.deployProxy(FixedSwapNFT, [accounts[0]], {initializer: "initialize"})
  console.log('Fix Swap address:', fixswap.address)
  const indexer = await upgrades.deployProxy(NFTIndexer, [accounts[0]], {initializer: "initialize"})
  console.log('NFT Indexer address:', indexer.address)

  await dfa721.setBaseURI("https://api.de-fine.art/v2/tokens/1/ERC721/")
  await fixswap.setIndexer(indexer.address)
  await indexer.setFixswap(fixswap.address)
  await indexer.setAuction(auction.address)
  await auction.setIndexer(indexer.address)

  await fixswap.setFee(200)
  await fixswap.setFeeMax(10000)
  await auction.setFee(200)
  await auction.setFeeMax(10000)

  await dfa721.setArtist("0x1D1Cf610c434c240654D2D1723698Ff03Eef7B0C", true)
}

main()
.then(() => process.exit(0))
.catch(error => {
  console.error(error);
  process.exit(1);
});
