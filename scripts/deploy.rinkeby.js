
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
    console.log("deploying EnglishAuctionNFT")
    //const auction = await upgrades.deployProxy(EnglishAuctionNFT, [accounts[0]], {initializer: "initialize"})
    const auction = await EnglishAuctionNFT.attach("0xF6D908305437d85d853D3fc774626324A23FD905")
    //console.log("EnglishAuctionNFT address:", auction.address)
    //console.log("deploying FixedSwapNFT")
    //const fixswap = await upgrades.deployProxy(FixedSwapNFT, [accounts[0]], {initializer: "initialize"})
    const fixswap = await upgrades.upgradeProxy("0xcB09F91DAe73B905B4Fb4081449753499CC44D56", FixedSwapNFT)
    //const fixswap = await EnglishAuctionNFT.attach("0xcB09F91DAe73B905B4Fb4081449753499CC44D56")
    //console.log("FixedSwapNFT address:", swap.address)
    // console.log("deploying NFTIndexer")
    //const nftindexer = await upgrades.deployProxy(NFTIndexer, [accounts[0]], {initializer: "initialize"})
    //console.log("NFTIndexer", nftindexer.address)
    const nftindexer = await NFTIndexer.attach('0x4C1ecb99DBD318016F25Ff11EBea68ae657123a6')
    //const dfa721 = await DFA721NFT.deploy("d", "d", "staging-api.de-fine.art/api/tokens/")
    //const dfa721 = await DFA721NFT.attach('0x33fcfF4a20791513795C507769087a0058a09691')
    //const fixswap = await FixedSwapNFT.attach("0x2AC3dC84467F7EFBBa0179dBfA57552bA2fcec8A")
    //await nftindexer.setAuction('0xb4B6ff2466a6BFeD096e3587E5F1829F2BeEF336')
    console.log(fixswap.address)
    console.log(auction.address)
    console.log(nftindexer.address)
    //await nftindexer.setAuction(auction.address)
    //await nftindexer.setAuction(auction.address)
    //await auction.setIndexer(nftindexer.address)
    //const nft_auction = await nftindexer.auction()
    //const dfa1155 = await DFA1155NFT.deploy("d", "d", "staging-api.de-fine.art/api/tokens/")
    //const dfa1155 = await DFA1155NFT.attach('0x4984BdA1485b7Ec7DC3789aF408118B507FB303c')
    //await dfa721.setArtist("0x1D1Cf610c434c240654D2D1723698Ff03Eef7B0C", true)
    // await dfa1155.setArtist("0x700BCC47dd1CeD09642DFf1CaF74A657B69b9F55", true)
    //let pool1 = await auction.getPoolCount()
    //let pool2 = await fixswap.getPoolCount()
    //console.log(pool1, pool2)

    //console.log(dfa721.address)
    //console.log(dfa1155.address)
    // const name =  await dfa721.name()
    // console.log(name)
    //const isArtist =  await dfa721.artist("0x1D1Cf610c434c240654D2D1723698Ff03Eef7B0C")
    //console.log(isArtist, name)
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
