
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
    const auction = await EnglishAuctionNFT.attach("0xb4B6ff2466a6BFeD096e3587E5F1829F2BeEF336")
    console.log("EnglishAuctionNFT address:", auction.address)
    console.log("deploying FixedSwapNFT")
    //const swap = await upgrades.deployProxy(FixedSwapNFT, [accounts[0]], {initializer: "initialize"})
    const swap = await EnglishAuctionNFT.attach("0x8A983395c855dAAD4F9D79D2cdbFaD067C853e94")
    console.log("FixedSwapNFT address:", swap.address)
    console.log("deploying NFTIndexer")
    //const nftindexer = await upgrades.deployProxy(NFTIndexer, [accounts[0]], {initializer: "initialize"})
    const nftindexer = await NFTIndexer.attach('0x25735113fA140c960450fF3b3CB038BC61e182FA')
    //const dfa721 = await DFA721NFT.deploy("d", "d", "staging-api.de-fine.art/api/tokens/")
    const dfa721 = await DFA721NFT.attach('0x33fcfF4a20791513795C507769087a0058a09691')
    await nftindexer.setAuction('0xb4B6ff2466a6BFeD096e3587E5F1829F2BeEF336')
    await nftindexer.setFixswap('0x8A983395c855dAAD4F9D79D2cdbFaD067C853e94')
    const nft_auction = await nftindexer.auction()
    const nft_fixswap = await nftindexer.fixswap()
    console.log('nft_auction', nft_auction)
    console.log('nft_fixedswap', nft_fixswap)
    //const dfa1155 = await DFA1155NFT.deploy("d", "d", "staging-api.de-fine.art/api/tokens/")
    //const dfa1155 = await DFA1155NFT.attach('0x4984BdA1485b7Ec7DC3789aF408118B507FB303c')
    //await dfa721.setArtist("0x1D1Cf610c434c240654D2D1723698Ff03Eef7B0C", true)
    //await dfa1155.setArtist("0x700BCC47dd1CeD09642DFf1CaF74A657B69b9F55", true)
    //console.log(dfa721.address)
    //console.log(dfa1155.address)
    // const name =  await dfa721.name()
    // console.log(name)
    const isArtist =  await dfa721.artist("0x1D1Cf610c434c240654D2D1723698Ff03Eef7B0C")
    //console.log(isArtist, name)
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
