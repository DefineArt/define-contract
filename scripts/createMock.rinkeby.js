async function main() {
    const { constants, provider, BigNumber, utils } = ethers;
    const { AddressZero } = constants;
    const ETH = utils.parseEther('1');
    const ZERO = BigNumber.from(0);
    const SUPPLY = ETH.mul(1000000);
    const STAKE_AMOUNT = ETH.mul(100);
    const MAX_SUPPLY = ETH.mul(120);
    const MAX_AMOUNT = ETH.mul(120);
    const FIL_AMOUNT = ETH.mul(100);
    const CONFIRMTIME = 2500;

    const EnglishAuctionNFT = await ethers.getContractFactory("EnglishAuctionNFT");
    const DFA721NFT = await ethers.getContractFactory("DFA721NFT");
    const DFA1155NFT = await ethers.getContractFactory("DFA1155NFT");
    const NFTIndexer = await ethers.getContractFactory("NFTIndexer");
    const dfa721 = await DFA721NFT.attach('0x5966c78727154cfc7bd5F791047F2319FDc2f8f7')
    const dfa1155 = await DFA1155NFT.attach('0x4984BdA1485b7Ec7DC3789aF408118B507FB303c')
    const creator = '0x1D1Cf610c434c240654D2D1723698Ff03Eef7B0C';
    const auction = await EnglishAuctionNFT.attach('0xcD3260bf3b3EbD706b5d44A608a8691ef386777c')

    await dfa721.approve(auction.address, 14);

    const name721 = "721 / TEST TOKEN";
    const token0721 = dfa721.address;
    const token1721 = '';
    const tokenId721 = 14;
    const amountMin1721 = ETH.div(100);
    const amountMinIncr1721 = ETH.div(5);
    const confirmTime721 = 30 * 60;
    
    await auction.createErc721(
        name721, token0721, token1721, tokenId721, amountMin1721, amountMinIncr1721, confirmTime721, {
        from: creator,
    });
    const pool721 = await auction.pools();
    console.log('pools', pool721);
}
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });