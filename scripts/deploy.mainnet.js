

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


    //const auction = await upgrades.upgradeProxy("0xaE2C96d0643180aEd6dc16192b6E1a0113b156cF", EnglishAuctionNFT)
    const auction = await EnglishAuctionNFT.attach("0xaE2C96d0643180aEd6dc16192b6E1a0113b156cF")
    //const fixswap = await upgrades.deployProxy(FixedSwapNFT, [accounts[0]], {initializer: "initialize"})
    const fixswap = await FixedSwapNFT.attach("0x53ec32583177ac5b2331ea7d1c11685317c03cdc")
    const dfa = await DFA721NFT.attach("0x70A76282752b5D2F09f81fe86D49d80ED8B53DC7")
    //const indexer = await upgrades.deployProxy(NFTIndexer, [accounts[0]], {initializer: "initialize"})
    const indexer = await NFTIndexer.attach("0x639636207a5db7322d007c9035ea0f29edc21b82")
    //const count = await auction.getPoolCount()

    //await dfa.setBaseURI("https://api.de-fine.art/v2/tokens/1/ERC721/")
    //await fixswap.setIndexer(indexer.address)
    //await indexer.setFixswap(fixswap.address)

    //await fixswap.setFee(200)
    //await fixswap.setFeeMax(10000)
    await dfa.setArtist("0x7FcD027b938ecaAfa33B2DA68A23e396787CCE20", true)

        /*
    for (let i = 9; i < count; i ++ ) {
        pool  = await auction.pools(i)
        if (pool.token0.toLowerCase() == "0x70A76282752b5D2F09f81fe86D49d80ED8B53DC7".toLowerCase()) {
            //console.log('set ', pool.tokenId, i)
            await indexer.new721Auction("0x70A76282752b5D2F09f81fe86D49d80ED8B53DC7", pool.tokenId, i);
        }
    }*/
        /*const poolid = await indexer.get721Auction("0x70A76282752b5D2F09f81fe86D49d80ED8B53DC7", 22);
    const pool = await auction.pools(12)
    console.log(pool, poolid, count)
    */

    //await indexer.setAuction(auction.address)
    //await auction.setIndexer(indexer.address)
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
