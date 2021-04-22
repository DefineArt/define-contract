const { expect } = require('chai');
const chai = require('chai');
const { solidity } = require('ethereum-waffle');

chai.use(solidity);
async function main() {
  const { constants, provider, BigNumber, utils } = ethers;

    const { AddressZero } = constants;
    const ETH = utils.parseEther('1');
    const creator = '0x1D1Cf610c434c240654D2D1723698Ff03Eef7B0C';
    const ZERO = BigNumber.from(0);
    const SUPPLY = ETH.mul(1000000);
    const STAKE_AMOUNT = ETH.mul(100);
    const MAX_SUPPLY = ETH.mul(120);
    const MAX_AMOUNT = ETH.mul(120);
    const FIL_AMOUNT = ETH.mul(100);
    const CONFIRMTIME = 2500;
  
    this.EnglishAuctionNFT = await ethers.getContractFactory("EnglishAuctionNFT");
    this.DFA721NFT = await ethers.getContractFactory("DFA721NFT");
    this.NFTIndexer = await ethers.getContractFactory("NFTIndexer");

    let dfa = await DFA721NFT.attach('0xF02e9f5f063912998163069DcDaC2d6b6F9000e4');
    let indexer = await NFTIndexer.attach('0x6b21Edd92822E6Edf3a50b3b49Bf9885C3c0Bed0');
    let auction = await EnglishAuctionNFT.attach('0x2313acEd4Acc8065886744049D848B6eFB80F34D');
    await indexer.setAuction(auction.address)
    await auction.setIndexer(indexer.address)

    await dfa.setArtist(creator, true)
    console.log('approved')
    //await dfa.connect(creator).mint();
    await dfa.approve(auction.address, 1)
    await auction.connect(creator).createErc721("ERC721", dfa.address, AddressZero, 1, ETH, ETH, CONFIRMTIME, false)
    await ethers.provider.send("evm_increaseTime", [CONFIRMTIME])
    poolid = await indexer.get721Auction(dfa.address, 2);
    console.log('pools', poolid);
}
main()
  .then(() => process.exit(0))  
  .catch(error => {
    console.error(error);
    process.exit(1);
  });