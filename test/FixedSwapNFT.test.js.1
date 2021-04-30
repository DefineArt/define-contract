// Load dependencies
const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { expect } = require('chai');
const { BN, constants, ether, expectEvent, expectRevert, time } = require('@openzeppelin/test-helpers');
const { ZERO_ADDRESS } = constants;

// Load compiled artifacts
const FixedSwapNFT = contract.fromArtifact('FixedSwapNFT');
const USDT = contract.fromArtifact(require('path').resolve('test/TetherToken'));
const ERC20 = contract.fromArtifact(require('path').resolve('test/ERC20'));
const ERC721 = contract.fromArtifact(require('path').resolve('test/ERC721'));
const ERC1155 = contract.fromArtifact(require('path').resolve('test/ERC1155'));


function usd (n) {
    return ether(n).div(new BN('10').pow(new BN('12')));
}

// Start test block
describe('FixedSwapNFT', function () {
    const [ owner, creator, governor, buyer ] = accounts;

    beforeEach(async function () {
        // Deploy FixedSwapNFT contract for each test
        this.FPNFT = await FixedSwapNFT.new({ from: owner });

        const cap = ether('500000');
        // Deploy a ERC20 contract for each test
        this.erc20Token = await ERC20.new('ERC20 Token', 'E20', cap, { from: owner });
        this.usdToken = await USDT.new(usd('500000'), 'USD Token', 'USDT', 6, { from: owner });

        // Deploy a ERC721 contract for each test
        this.erc721 = await ERC721.new( { from: owner });
        this.erc721.initialize("NFT", "BNFT", { from: owner });

        // Deploy a ERC1155 contract for each test
        this.erc1155 = await ERC1155.new('http://example.com', { from: owner });

        // initialize FixedSwapNFT contract
        await this.FPNFT.initialize(governor, { from: owner });
        await expectRevert(this.FPNFT.initialize(governor, { from: governor }), 'Contract instance has already been initialized.');

        // mint ERC20 token
        await this.erc20Token.mint(this.FPNFT.address, ether('10000'), { from: owner });
        await this.erc20Token.mint(creator, ether('10000'), { from: owner });
        await this.erc20Token.mint(buyer, ether('10000'), { from: owner });
        // mint USD token
        await this.usdToken.transfer(creator, usd('10000'), { from: owner });
        await this.usdToken.transfer(buyer, usd('10000'), { from: owner });
        // mint ERC721 token
        await this.erc721.mint(creator, 0, { from: owner });
        await this.erc721.mint(creator, 1, { from: owner });
        await this.erc721.mint(creator, 2, { from: owner });
        expect(await this.erc721.ownerOf(0)).to.equal(creator);
        expect(await this.erc721.ownerOf(1)).to.equal(creator);
        expect(await this.erc721.ownerOf(2)).to.equal(creator);
        expect(await this.erc721.balanceOf(creator)).to.be.bignumber.equal(new BN('3'));
        // mint ERC1155 token
        await this.erc1155.mint(creator, 0, 10, [], { from: owner });
        await this.erc1155.mint(creator, 1, 20, [], { from: owner });
        await this.erc1155.mint(creator, 2, 30, [], { from: owner });
        expect(await this.erc1155.balanceOf(creator, 0)).to.be.bignumber.equal(new BN('10'));
        expect(await this.erc1155.balanceOf(creator, 1)).to.bignumber.equal(new BN('20'));
        expect(await this.erc1155.balanceOf(creator, 2)).to.bignumber.equal(new BN('30'));
    });

    describe('create ERC721/ETH', function () {
        beforeEach(async function () {
            const name = "ERC721/ETH";
            const token0 = this.erc721.address;
            const token1 = ZERO_ADDRESS;
            const tokenId = 0;
            const amountTotal1 = ether('10');
            const duration = 3600;
            const index = 0;
            await this.erc721.approve(this.FPNFT.address, tokenId, { from: creator });
            await this.FPNFT.createErc721(
                name, token0, token1, tokenId, amountTotal1, duration, {
                    from: creator,
                });
            const pool = await this.FPNFT.pools(index);
            expect(pool.name).to.equal(name);
            expect(pool.creator).to.equal(creator);
            expect(pool.token0).to.equal(token0);
            expect(pool.token1).to.equal(token1);
            expect(pool.tokenId).to.be.bignumber.equal(new BN('0'));
            expect(pool.amountTotal0).to.be.bignumber.equal(new BN('1'));
            expect(pool.amountTotal1).to.be.bignumber.equal(amountTotal1);
            expect(pool.closeAt).to.be.bignumber.gt(new BN(duration));
            expect(pool.nftType).to.be.bignumber.equal(new BN('0'));
            expect(await this.FPNFT.swappedP(index)).to.equal(false);
            expect(await this.FPNFT.myCreatedP(creator)).to.be.bignumber.equal(new BN('1'));
            expect(await this.FPNFT.creatorClaimedP(index)).to.equal(false);
            expect(await this.erc721.ownerOf(0)).to.equal(this.FPNFT.address);
        });

        it('when swap should be ok', async function () {
            const index = 0;
            const amount0 = new BN('1');
            const amount1 = ether('10');
            await this.FPNFT.swap(index, amount0, { from: buyer, value: amount1 });
            expect(await this.FPNFT.swappedP(index)).to.equal(true);
            await expectRevert(
                this.FPNFT.swap(index, amount0, { from: buyer, value: amount1 }),
                "this pool is swapped"
            );
            expect(await this.erc721.ownerOf(0)).to.equal(buyer);
        });

        it('when swap with invalid amount should throw exception', async function () {
            const index = 0;
            const amount0 = new BN('1');
            const amount1 = ether('9');
            await expectRevert(
                this.FPNFT.swap(index, amount0, { from: buyer, value: amount1 }),
                "invalid ETH amount"
            );
        });

        it('when claim should be ok', async function () {
            const index = 0;
            await time.increase(time.duration.days(1));
            expect(await this.erc721.ownerOf(0)).to.equal(this.FPNFT.address);
            this.FPNFT.creatorClaim(index, { from: creator });
            expect(await this.erc721.ownerOf(0)).to.equal(creator);
            expect(await this.erc721.ownerOf(1)).to.equal(creator);
            expect(await this.erc721.ownerOf(2)).to.equal(creator);
            expect(await this.erc721.balanceOf(creator)).to.be.bignumber.equal(new BN('3'));
            await expectRevert(
                this.FPNFT.creatorClaim(index, { from: buyer }),
                "sender is not pool creator"
            );
        });

        it('when re-create should be ok', async function () {
            const name = "ERC721/ETH";
            const token0 = this.erc721.address;
            const token1 = ZERO_ADDRESS;
            const tokenId = 1;
            const amountTotal1 = ether('10');
            const duration = 3600;
            const index = 0;

            await this.erc721.approve(this.FPNFT.address, tokenId, { from: creator });

            await expectRevert(
                this.FPNFT.createErc721(
                    name, token0, token1, tokenId, amountTotal1, duration, {
                        from: creator,
                    }),
                "a pool has created by this address"
            );

            await time.increase(time.duration.days(1));
            this.FPNFT.creatorClaim(index, { from: creator });

            await this.FPNFT.createErc721(
                name, token0, token1, tokenId, amountTotal1, duration, {
                    from: creator,
                });
        });

    });

    describe('create ERC1155/ETH', function () {
        beforeEach(async function () {
            const name = "ERC1155/ETH";
            const token0 = this.erc1155.address;
            const token1 = ZERO_ADDRESS;
            const tokenId = 0;
            const amountTotal0 = new BN('10');
            const amountTotal1 = ether('10');
            const duration = 3600;
            const index = 0;

            await this.erc1155.setApprovalForAll(this.FPNFT.address, true, { from: creator });
            await this.FPNFT.createErc1155(
                name, token0, token1, tokenId, amountTotal0, amountTotal1, duration, {
                    from: creator,
                });
            const pool = await this.FPNFT.pools(index);
            expect(pool.name).to.equal(name);
            expect(pool.creator).to.equal(creator);
            expect(pool.token0).to.equal(token0);
            expect(pool.tokenId).to.be.bignumber.equal(new BN('0'));
            expect(pool.amountTotal0).to.be.bignumber.equal(new BN('10'));
            expect(pool.amountTotal1).to.be.bignumber.equal(amountTotal1);
            expect(pool.closeAt).to.be.bignumber.gt(new BN(duration));
            expect(pool.nftType).to.be.bignumber.equal(new BN('1'));
            expect(await this.FPNFT.swappedP(index)).to.equal(false);
            expect(await this.FPNFT.myCreatedP(creator)).to.be.bignumber.equal(new BN('1'));
            expect(await this.FPNFT.creatorClaimedP(index)).to.equal(false);
            expect(await this.erc1155.balanceOf(this.FPNFT.address, 0)).to.be.bignumber.equal(new BN('10'));
        });

        it('when swap should be ok', async function () {
            const index = 0;
            const amount0 = new BN('10');
            const amount1 = ether('10');
            await this.FPNFT.swap(index, amount0, { from: buyer, value: amount1 });
            expect(await this.FPNFT.swappedP(index)).to.equal(true);
            await expectRevert(
                this.FPNFT.swap(index, amount0, { from: buyer, value: amount1 }),
                "this pool is swapped"
            );
            expect(await this.erc1155.balanceOf(buyer, 0)).to.bignumber.equal(new BN('10'));
            expect(await this.erc1155.balanceOf(creator, 1)).to.bignumber.equal(new BN('20'));
            expect(await this.erc1155.balanceOf(creator, 2)).to.bignumber.equal(new BN('30'));
        });

        it('when swap with invalid amount should throw exception', async function () {
            const index = 0;
            const amount0 = new BN('10');
            const amount1 = ether('9');
            await expectRevert(
                this.FPNFT.swap(index, amount0, { from: buyer, value: amount1 }),
                "invalid ETH amount"
            );
        });

        it('when claim should be ok', async function () {
            const index = 0;
            await time.increase(time.duration.days(1));
            expect(await this.erc1155.balanceOf(this.FPNFT.address, 0)).to.bignumber.equal(new BN('10'));
            this.FPNFT.creatorClaim(index, { from: creator });
            expect(await this.erc1155.balanceOf(creator, 0)).to.bignumber.equal(new BN('10'));
            expect(await this.erc1155.balanceOf(creator, 1)).to.bignumber.equal(new BN('20'));
            expect(await this.erc1155.balanceOf(creator, 2)).to.bignumber.equal(new BN('30'));
            await expectRevert(
                this.FPNFT.creatorClaim(index, { from: buyer }),
                "sender is not pool creator"
            );
        });
    });

    describe('create ERC721/USDT', function () {
        beforeEach(async function () {
            const name = "ERC721/USDT";
            const token0 = this.erc721.address;
            const token1 = this.usdToken.address;
            const tokenId = 0;
            const amountTotal1 = usd('10');
            const duration = 3600;
            const index = 0;
            await this.erc721.approve(this.FPNFT.address, tokenId, { from: creator });
            await this.FPNFT.createErc721(
                name, token0, token1, tokenId, amountTotal1, duration, {
                    from: creator,
                });
            const pool = await this.FPNFT.pools(index);
            expect(pool.name).to.equal(name);
            expect(pool.creator).to.equal(creator);
            expect(pool.token0).to.equal(token0);
            expect(pool.token1).to.equal(token1);
            expect(pool.tokenId).to.be.bignumber.equal(new BN('0'));
            expect(pool.amountTotal0).to.be.bignumber.equal(new BN('1'));
            expect(pool.amountTotal1).to.be.bignumber.equal(amountTotal1);
            expect(pool.closeAt).to.be.bignumber.gt(new BN(duration));
            expect(pool.nftType).to.be.bignumber.equal(new BN('0'));
            expect(await this.FPNFT.swappedP(index)).to.equal(false);
            expect(await this.FPNFT.myCreatedP(creator)).to.be.bignumber.equal(new BN('1'));
            expect(await this.FPNFT.creatorClaimedP(index)).to.equal(false);
            expect(await this.erc721.ownerOf(0)).to.equal(this.FPNFT.address);
        });

        it('when swap should be ok', async function () {
            const index = 0;
            const amount0 = new BN('1');
            const amount1 = usd('10');
            await this.usdToken.approve(this.FPNFT.address, amount1, { from: buyer });
            await this.FPNFT.swap(index, amount0, { from: buyer });
            expect(await this.FPNFT.swappedP(index)).to.equal(true);
            expect(await this.usdToken.balanceOf(creator)).to.be.bignumber.equal(usd('10010'));
            expect(await this.usdToken.balanceOf(buyer)).to.be.bignumber.equal(usd('9990'));
            await this.usdToken.approve(this.FPNFT.address, amount1, { from: buyer });
            await expectRevert(
                this.FPNFT.swap(index, amount0, { from: buyer }),
                "this pool is swapped"
            );
            expect(await this.erc721.ownerOf(0)).to.equal(buyer);
        });

        it('when swap with invalid amount should throw exception', async function () {
            const index = 0;
            const amount0 = new BN('1');
            const amount1 = usd('9');
            await this.usdToken.approve(this.FPNFT.address, amount1, { from: buyer });
            await expectRevert(
                this.FPNFT.swap(index, amount0, { from: buyer }),
                "SafeERC20: low-level call failed"
            );
        });

        it('when claim should be ok', async function () {
            const index = 0;
            await time.increase(time.duration.days(1));
            expect(await this.erc721.ownerOf(0)).to.equal(this.FPNFT.address);
            this.FPNFT.creatorClaim(index, { from: creator });
            expect(await this.erc721.ownerOf(0)).to.equal(creator);
            expect(await this.erc721.ownerOf(1)).to.equal(creator);
            expect(await this.erc721.ownerOf(2)).to.equal(creator);
            expect(await this.erc721.balanceOf(creator)).to.be.bignumber.equal(new BN('3'));
            expect(await this.usdToken.balanceOf(creator)).to.be.bignumber.equal(usd('10000'));
            expect(await this.usdToken.balanceOf(buyer)).to.be.bignumber.equal(usd('10000'));
            await expectRevert(
                this.FPNFT.creatorClaim(index, { from: buyer }),
                "sender is not pool creator"
            );
        });
    });

    describe('create ERC1155/USDT', function () {
        beforeEach(async function () {
            const name = "ERC1155/ETH";
            const token0 = this.erc1155.address;
            const token1 = this.usdToken.address;
            const tokenId = 0;
            const amountTotal0 = new BN('10');
            const amountTotal1 = usd('10');
            const duration = 3600;
            const index = 0;

            await this.erc1155.setApprovalForAll(this.FPNFT.address, true, { from: creator });
            await this.FPNFT.createErc1155(
                name, token0, token1, tokenId, amountTotal0, amountTotal1, duration, {
                    from: creator,
                });
            const pool = await this.FPNFT.pools(index);
            expect(pool.name).to.equal(name);
            expect(pool.creator).to.equal(creator);
            expect(pool.token0).to.equal(token0);
            expect(pool.tokenId).to.be.bignumber.equal(new BN('0'));
            expect(pool.amountTotal0).to.be.bignumber.equal(new BN('10'));
            expect(pool.amountTotal1).to.be.bignumber.equal(amountTotal1);
            expect(pool.closeAt).to.be.bignumber.gt(new BN(duration));
            expect(pool.nftType).to.be.bignumber.equal(new BN('1'));
            expect(await this.FPNFT.swappedP(index)).to.equal(false);
            expect(await this.FPNFT.myCreatedP(creator)).to.be.bignumber.equal(new BN('1'));
            expect(await this.FPNFT.creatorClaimedP(index)).to.equal(false);
            expect(await this.erc1155.balanceOf(this.FPNFT.address, 0)).to.be.bignumber.equal(new BN('10'));
        });

        it('when swap should be ok', async function () {
            const index = 0;
            const amount0 = new BN('10');
            const amount1 = usd('10');
            await this.usdToken.approve(this.FPNFT.address, amount1, { from: buyer });
            await this.FPNFT.swap(index, amount0, { from: buyer });
            expect(await this.FPNFT.swappedP(index)).to.equal(true);
            expect(await this.usdToken.balanceOf(creator)).to.be.bignumber.equal(usd('10010'));
            expect(await this.usdToken.balanceOf(buyer)).to.be.bignumber.equal(usd('9990'));
            await this.usdToken.approve(this.FPNFT.address, amount1, { from: buyer });
            await expectRevert(
                this.FPNFT.swap(index, amount0, { from: buyer }),
                "this pool is swapped"
            );
            expect(await this.erc1155.balanceOf(buyer, 0)).to.bignumber.equal(new BN('10'));
            expect(await this.erc1155.balanceOf(creator, 1)).to.bignumber.equal(new BN('20'));
            expect(await this.erc1155.balanceOf(creator, 2)).to.bignumber.equal(new BN('30'));
        });

        it('when swap with invalid amount should throw exception', async function () {
            const index = 0;
            const amount0 = new BN('10');
            const amount1 = usd('9');
            await this.usdToken.approve(this.FPNFT.address, amount1, { from: buyer });
            await expectRevert(
                this.FPNFT.swap(index, amount0, { from: buyer }),
                "SafeERC20: low-level call failed"
            );
        });

        it('when claim should be ok', async function () {
            const index = 0;
            await time.increase(time.duration.days(1));
            expect(await this.erc1155.balanceOf(this.FPNFT.address, 0)).to.bignumber.equal(new BN('10'));
            this.FPNFT.creatorClaim(index, { from: creator });
            expect(await this.erc1155.balanceOf(creator, 0)).to.bignumber.equal(new BN('10'));
            expect(await this.erc1155.balanceOf(creator, 1)).to.bignumber.equal(new BN('20'));
            expect(await this.erc1155.balanceOf(creator, 2)).to.bignumber.equal(new BN('30'));
            expect(await this.usdToken.balanceOf(creator)).to.be.bignumber.equal(usd('10000'));
            expect(await this.usdToken.balanceOf(buyer)).to.be.bignumber.equal(usd('10000'));
            await expectRevert(
                this.FPNFT.creatorClaim(index, { from: buyer }),
                "sender is not pool creator"
            );
        });
    });
});
