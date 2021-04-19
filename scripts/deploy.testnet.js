
async function main() {
    const { provider, BigNumber, utils } = ethers;
    const ETH = utils.parseEther('1');
    const accounts = await ethers.provider.listAccounts()
    console.log('owner address', accounts[0])
    const EnglishAuctionNFT = await ethers.getContractFactory("EnglishAuctionNFT");
    const FixedSwapNFT = await ethers.getContractFactory("FixedSwapNFT");
    const DFA721NFT = await ethers.getContractFactory("DFA721NFT");
    const DFA1155NFT = await ethers.getContractFactory("DFA1155NFT");
    console.log("deploying EnglishAuctionNFT")
    //const auction = await upgrades.deployProxy(EnglishAuctionNFT, [accounts[0]], {initializer: "initialize"})
    const auction = await EnglishAuctionNFT.attach("0xef1C46Bb077f0e802Df86a578ce928EE58f3c762")
    console.log("EnglishAuctionNFT address:", auction.address)
    console.log("deploying FixedSwapNFT")
    //const swap = await upgrades.deployProxy(FixedSwapNFT, [accounts[0]], {initializer: "initialize"})
    const swap = await EnglishAuctionNFT.attach("0xd15EE05677B03373BE57076c72De5e928186553A")
    console.log("FixedSwapNFT address:", swap.address)

    //const dfa721 = await DFA721NFT.deploy("d", "d", "staging-api.de-fine.art/api/tokens/")
    const dfa721 = await DFA721NFT.attach('0xC2F81FE51ed251F9a7631BA3FeAC8388b67257B5')
    //const dfa1155 = await DFA1155NFT.deploy("d", "d", "staging-api.de-fine.art/api/tokens/")
    const dfa1155 = await DFA1155NFT.attach('0x4984BdA1485b7Ec7DC3789aF408118B507FB303c')
    await dfa721.setArtist("0x700BCC47dd1CeD09642DFf1CaF74A657B69b9F55", true)
    await dfa1155.setArtist("0x700BCC47dd1CeD09642DFf1CaF74A657B69b9F55", true)
    console.log(dfa721.address)
    console.log(dfa1155.address)
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
