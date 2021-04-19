const { expect } = require('chai');
const chai = require('chai');
const { solidity } = require('ethereum-waffle');

chai.use(solidity);

describe('test auction', function () {

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

  let dfa;
  let auction;
  let indexer;
  let owner, creator1, creator2, bidder1, bidder2;

  before(async function () {
      this.EnglishAuctionNFT = await ethers.getContractFactory("EnglishAuctionNFT");
      this.DFA721NFT = await ethers.getContractFactory("DFA721NFT");
      this.NFTIndexer = await ethers.getContractFactory("NFTIndexer");
      [owner, creator1, creator2, bidder1, bidder2] = await ethers.getSigners();
  });

  beforeEach(async function () {
      dfa = await this.DFA721NFT.deploy("d", "d", "d");
      indexer = await upgrades.deployProxy(this.NFTIndexer, [owner.address], {initializer: "initialize"});
      auction = await upgrades.deployProxy(this.EnglishAuctionNFT, [owner.address], {initializer: "initialize"});
      await indexer.setAuction(auction.address)
      await auction.setIndexer(indexer.address);
  });

  describe('#721 auction', () => {

    beforeEach('auction', async () => {
        await dfa.connect(owner).setArtist(creator1.address, true);
        await dfa.connect(creator1).mint();
        await dfa.connect(creator1).mint();
        await dfa.connect(creator1).approve(auction.address, 1);
        await dfa.connect(creator1).approve(auction.address, 2);
    });

    it('auction should work correctly', async () => {
      const name = "ERC721";
      await auction.connect(creator1).createErc721(name, dfa.address, AddressZero, 1, ETH, ETH, CONFIRMTIME, false)
      await auction.connect(creator1).createErc721(name, dfa.address, AddressZero, 2, ETH, ETH, CONFIRMTIME, false)
      await expect(auction.connect(bidder1).bid(1, ETH, {value: ETH}))
        .to.emit(auction, 'Bid')
        .withArgs(bidder1.address, 1, ETH);
      await ethers.provider.send("evm_increaseTime", [CONFIRMTIME])
      let poolid = await indexer.get721Auction(dfa.address, 2);
      expect(poolid.toString()).to.equal("1")
      await expect(auction.connect(bidder1).bidderClaim(1))
        .to.emit(auction, 'Claimed')
        .withArgs(bidder1.address, 1)
      poolid = await indexer.get721Auction(dfa.address, 1);
      expect(poolid.toString()).to.equal("0")
    });


  }); 

});
