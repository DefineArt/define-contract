// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./Governable.sol";
import "./interfaces/IERC1155.sol";
import "./NFTIndexer.sol";

contract EnglishAuctionNFT is Configurable, IERC721Receiver {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 internal constant TypeErc721 = 0;
    uint256 internal constant TypeErc1155 = 1;
    address internal constant DeadAddress =
        0x000000000000000000000000000000000000dEaD;
    address internal constant UniSwapContract =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    struct Pool {
        // address of pool creator
        address payable creator;
        // pool name
        string name;
        // address of sell token
        address token0;
        // token id of token0
        uint256 tokenId;
        // amount of token id of token0
        uint256 tokenAmount0;
        // minimum amount of ETH that creator want to swap
        uint256 amountMin1;
        // minimum incremental amount of token1
        uint256 amountMinIncr1;
        // how many seconds the pool will be live since last bid
        uint256 confirmTime;
        // the timestamp in seconds the pool will be closed
        uint256 closeAt;
        // NFT token type
        uint256 nftType;
    }

    Pool[] public pools;

    // pool index => a flag that if creator is claimed the pool
    mapping(uint256 => bool) public creatorClaimedP;
    // pool index => the candidate of winner who bid the highest amount1 in current round
    mapping(uint256 => address payable) public currentBidderP;
    // pool index => the highest amount1 in current round
    mapping(uint256 => uint256) public currentBidderAmount1P;

    // name => pool index + 1
    mapping(string => uint256) public myNameP;

    // account => array of pool index
    mapping(address => uint256[]) public myBidP;
    // account => pool index => bid amount1
    mapping(address => mapping(uint256 => uint256)) public myBidderAmount1P;
    // account => pool index => claim flag
    mapping(address => mapping(uint256 => bool)) public myClaimedP;

    // pool index => bid count; v1.15.0
    mapping(uint256 => uint256) public bidCountP;
    // pool index => address of buy token; v1.16.0
    mapping(uint256 => address) public token1P;

    // check if token0 in whitelist
    bool public checkToken0;

    // token0 address => true or false
    mapping(address => bool) public token0List;

    uint256 public fee;

    uint256 public feeMax;

    address payable public feeTo;

    // pool add time after bid
    mapping(uint256 => bool) public poolTime;

    address indexer;

    // the timestamp in seconds the pool will start
    mapping(uint256 => uint256) public startAt;

    // promo token list
    mapping(address => uint256) public promoTokenList;

    event Created(
        address indexed sender,
        uint256 indexed index,
        Pool pool,
        address token1,
        uint256 startTime
    );
    event Bid(address sender, uint256 index, uint256 amount1, uint256 closeAt);
    event Claimed(address sender, uint256 index);
    event AuctionClosed(address indexed sender, uint256 indexed index);

    function initialize(address _governor) public override initializer {
        super.initialize(_governor);
    }

    function createErc721(
        // name of the pool
        string memory name,
        // address of token0
        address token0,
        // address of token1
        address token1,
        // token id of token0
        uint256 tokenId,
        // minimum amount of token1
        uint256 amountMin1,
        // minimum incremental amount of token1
        uint256 amountMinIncr1,
        // confirmation time
        uint256 confirmTime,
        // add close time after bid
        bool addTime
    ) external payable {
        if (checkToken0) {
            require(token0List[token0], "invalid token0");
        }
        uint256 tokenAmount0 = 1;
        uint256[3] memory amounts = [tokenAmount0, amountMin1, amountMinIncr1];
        _create(
            name,
            token0,
            token1,
            tokenId,
            amounts,
            confirmTime,
            TypeErc721,
            addTime,
            now
        );
        if (token1 != address(0)) {
            token1P[pools.length - 1] = token1;
        }
    }

    function createErc721WithStartTime(
        // name of the pool
        string memory name,
        // address of token0
        address token0,
        // address of token1
        address token1,
        // token id of token0
        uint256 tokenId,
        // minimum amount of token1
        uint256 amountMin1,
        // minimum incremental amount of token1
        uint256 amountMinIncr1,
        // confirmation time
        uint256 confirmTime,
        // add close time after bid
        bool addTime,
        uint256 startTime
    ) external payable {
        if (checkToken0) {
            require(token0List[token0], "invalid token0");
        }
        uint256 tokenAmount0 = 1;
        uint256[3] memory amounts = [tokenAmount0, amountMin1, amountMinIncr1];
        _create(
            name,
            token0,
            token1,
            tokenId,
            amounts,
            confirmTime,
            TypeErc721,
            addTime,
            startTime
        );
        if (token1 != address(0)) {
            token1P[pools.length - 1] = token1;
        }
    }

    function createErc1155WithStartTime(
        // name of the pool
        string memory name,
        // address of token0
        address token0,
        // address of token1
        address token1,
        // token id of token0
        uint256 tokenId,
        // amount of token id of token0
        uint256 tokenAmount0,
        // minimum amount of token1
        uint256 amountMin1,
        // minimum incremental amount of token1
        uint256 amountMinIncr1,
        // confirmation time
        uint256 confirmTime,
        // add close time after bid
        bool addTime,
        uint256 startTime
    ) external payable {
        if (checkToken0) {
            require(token0List[token0], "invalid token0");
        }
        uint256[3] memory amounts = [tokenAmount0, amountMin1, amountMinIncr1];
        _create(
            name,
            token0,
            token1,
            tokenId,
            amounts,
            confirmTime,
            TypeErc1155,
            addTime,
            startTime
        );
        if (token1 != address(0)) {
            token1P[pools.length - 1] = token1;
        }
    }

    function createErc1155(
        // name of the pool
        string memory name,
        // address of token0
        address token0,
        // address of token1
        address token1,
        // token id of token0
        uint256 tokenId,
        // amount of token id of token0
        uint256 tokenAmount0,
        // minimum amount of token1
        uint256 amountMin1,
        // minimum incremental amount of token1
        uint256 amountMinIncr1,
        // confirmation time
        uint256 confirmTime,
        // add close time after bid
        bool addTime
    ) external payable {
        if (checkToken0) {
            require(token0List[token0], "invalid token0");
        }
        uint256[3] memory amounts = [tokenAmount0, amountMin1, amountMinIncr1];
        _create(
            name,
            token0,
            token1,
            tokenId,
            amounts,
            confirmTime,
            TypeErc1155,
            addTime,
            now
        );
        if (token1 != address(0)) {
            token1P[pools.length - 1] = token1;
        }
    }

    function _create(
        // name of the pool
        string memory name,
        // address of token0
        address token0,
        // address of token1
        address token1,
        // token id of token0
        uint256 tokenId,
        // 0: uint tokenAmount0, amount of token id of token0
        // 1: uint amountMin1, minimum amount of token1
        // 2: uint amountMinIncr1, minimum incremental amount of token1
        uint256[3] memory amounts,
        // confirmation time
        uint256 confirmTime,
        // NFT token type
        uint256 nftType,
        bool addTime,
        uint256 startTime
    ) private {
        address payable creator = msg.sender;

        require(startTime > 0, "start time should not be zero");
        require(amounts[0] != 0, "the value of tokenAmount0 is zero");
        require(amounts[2] != 0, "the value of amountMinIncr1 is zero");
        require(
            confirmTime >= 5 minutes,
            "the value of confirmTime less than 5 minutes"
        );
        require(
            confirmTime <= 7 days,
            "the value of confirmTime is exceeded 7 days"
        );
        require(bytes(name).length <= 15, "the length of name is too long");

        // creator pool
        Pool memory pool;
        pool.creator = creator;
        pool.name = name;
        pool.token0 = token0;
        pool.tokenId = tokenId;
        pool.tokenAmount0 = amounts[0];
        pool.amountMin1 = amounts[1];
        pool.amountMinIncr1 = amounts[2];
        pool.confirmTime = confirmTime;
        pool.closeAt = startTime.add(confirmTime);
        pool.nftType = nftType;

        uint256 index = pools.length;
        pools.push(pool);
        poolTime[pools.length - 1] = addTime;

        startAt[index] = startTime;

        // transfer tokenId of token0 to this contract
        if (nftType == TypeErc721) {
            IERC721(token0).safeTransferFrom(creator, address(this), tokenId);
            NFTIndexer(indexer).new721Auction(
                token0,
                tokenId,
                pools.length - 1
            );
        } else {
            IERC1155(token0).safeTransferFrom(
                creator,
                address(this),
                tokenId,
                amounts[0],
                ""
            );
            NFTIndexer(indexer).new1155Auction(
                token0,
                creator,
                tokenId,
                pools.length - 1
            );
        }

        emit Created(creator, index, pool, token1, startTime);
    }

    function bid(
        // pool index
        uint256 index,
        // amount of token1
        uint256 amount1
    )
        external
        payable
        isPoolExist(index)
        isPoolStarted(index)
        isPoolNotClosed(index)
    {
        address payable sender = msg.sender;

        Pool storage pool = pools[index];
        require(
            pool.creator != sender,
            "creator can't bid the pool created by self"
        );
        require(amount1 != 0, "the value of amount1 is zero");
        require(
            amount1 >= pool.amountMin1,
            "the bid amount is lower than minimum bidder amount"
        );

        require(
            amount1 >= currentBidderAmount(index),
            "the bid amount is lower than the current bidder amount"
        );

        address token1 = token1P[index];
        if (token1 == address(0)) {
            require(amount1 == msg.value, "invalid ETH amount");
        } else {
            IERC20(token1).safeTransferFrom(sender, address(this), amount1);
            IERC20(token1).safeApprove(address(this), 0);
        }

        // return ETH to previous bidder
        if (
            currentBidderP[index] != address(0) &&
            currentBidderAmount1P[index] > 0
        ) {
            if (token1 == address(0)) {
                currentBidderP[index].transfer(currentBidderAmount1P[index]);
            } else {
                IERC20(token1).transfer(
                    currentBidderP[index],
                    currentBidderAmount1P[index]
                );
            }
        }

        // update closeAt
        if (poolTime[index] == true) {
            pool.closeAt = now.add(pool.confirmTime);
        }

        // record new winner
        currentBidderP[index] = sender;
        currentBidderAmount1P[index] = amount1;
        bidCountP[index] = bidCountP[index] + 1;

        myBidP[sender].push(index);
        myBidderAmount1P[sender][index] = amount1;

        emit Bid(sender, index, amount1, pool.closeAt);
    }

    function creatorClaim(uint256 index)
        external
        isPoolExist(index)
        isPoolClosed(index)
    {
        address payable sender = msg.sender;
        require(isCreator(sender, index), "sender is not pool creator");
        require(!creatorClaimedP[index], "creator has claimed this pool");

        _creatorClaim(index);

        if (currentBidderP[index] != address(0)) {
            address bidder = currentBidderP[index];
            if (!myClaimedP[bidder][index]) {
                _bidderClaim(bidder, index);
            }
        }
    }

    function bidderClaim(uint256 index)
        external
        isPoolExist(index)
        isPoolClosed(index)
    {
        address payable sender = msg.sender;
        require(
            currentBidderP[index] == sender,
            "sender is not the winner of this pool"
        );
        require(!myClaimedP[sender][index], "sender has claimed this pool");

        _bidderClaim(sender, index);

        if (!creatorClaimedP[index]) {
            _creatorClaim(index);
        }
    }

    function _creatorClaim(uint256 index) internal {
        creatorClaimedP[index] = true;
        Pool memory pool = pools[index];

        if (currentBidderP[index] != address(0)) {
            address payable winner = currentBidderP[index];
            uint256 amount1 = currentBidderAmount1P[index];

            uint256 auctionFee = 0;
            if (feeTo != address(0) && fee > 0) {
                if (promoTokenList[token1P[index]] != 0) {
                    auctionFee = amount1
                        .mul(promoTokenList[token1P[index]])
                        .div(feeMax);
                } else {
                    auctionFee = amount1.mul(fee).div(feeMax);
                }
            }

            if (amount1 > 0) {
                if (token1P[index] == address(0)) {
                    // transfer ETH to creator
                    if (auctionFee > 0) {
                        feeTo.transfer(auctionFee);
                    }
                    pool.creator.transfer(amount1.sub(auctionFee));
                } else {
                    if (auctionFee > 0) {
                        IERC20(token1P[index]).transfer(feeTo, auctionFee);
                    }
                    IERC20(token1P[index]).transfer(
                        pool.creator,
                        amount1.sub(auctionFee)
                    );
                }
            }
        } else {
            // transfer token0 back to creator
            if (pool.nftType == TypeErc721) {
                IERC721(pool.token0).safeTransferFrom(
                    address(this),
                    pool.creator,
                    pool.tokenId
                );
            } else {
                IERC1155(pool.token0).safeTransferFrom(
                    address(this),
                    pool.creator,
                    pool.tokenId,
                    pool.tokenAmount0,
                    ""
                );
            }
        }

        emit Claimed(pool.creator, index);
    }

    function _bidderClaim(address sender, uint256 index) internal {
        myClaimedP[sender][index] = true;

        Pool memory pool = pools[index];

        // transfer token0 to bidder
        if (pool.nftType == TypeErc721) {
            IERC721(pool.token0).safeTransferFrom(
                address(this),
                sender,
                pool.tokenId
            );
        } else {
            IERC1155(pool.token0).safeTransferFrom(
                address(this),
                sender,
                pool.tokenId,
                pool.tokenAmount0,
                ""
            );
        }

        emit Claimed(sender, index);
    }

    function closeAuction(uint256 index)
        external
        isPoolExist(index)
        isPoolNotClosed(index)
    {
        address payable sender = msg.sender;
        require(isCreator(sender, index), "sender is not pool creator");

        Pool storage pool = pools[index];
        pool.closeAt = now;

        emit AuctionClosed(sender, index);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function getPoolCount() external view returns (uint256) {
        return pools.length;
    }

    function getStartTime(uint256 index) external view returns (uint256) {
        return startAt[index];
    }

    function setFee(uint256 _fee) external governance returns (bool) {
        fee = _fee;
        return true;
    }

    function setFeeMax(uint256 _feeMax) external governance returns (bool) {
        feeMax = _feeMax;
        return true;
    }

    function setFeeTo(address payable _feeTo)
        external
        governance
        returns (bool)
    {
        feeTo = _feeTo;
        return true;
    }

    function setCheckToken0(bool _checkToken0)
        external
        governance
        returns (bool)
    {
        checkToken0 = _checkToken0;
        return true;
    }

    function setIndexer(address _indexer) external governance returns (bool) {
        indexer = _indexer;
        return true;
    }

    function setToken0List(address _token0, bool enable)
        external
        governance
        returns (bool)
    {
        token0List[_token0] = enable;
        return true;
    }

    function setPoolTime(uint256 index, bool add)
        external
        governance
        returns (bool)
    {
        poolTime[index] = add;
        return true;
    }

    function currentBidderAmount(uint256 index) public view returns (uint256) {
        Pool memory pool = pools[index];
        uint256 amount = pool.amountMin1;

        if (currentBidderP[index] != address(0)) {
            amount = currentBidderAmount1P[index].add(pool.amountMinIncr1);
        } else if (pool.amountMin1 == 0) {
            amount = pool.amountMinIncr1;
        }

        return amount;
    }

    function isCreator(address target, uint256 index)
        private
        view
        returns (bool)
    {
        if (pools[index].creator == target) {
            return true;
        }
        return false;
    }

    modifier isPoolClosed(uint256 index) {
        require(pools[index].closeAt <= now, "this pool is not closed");
        _;
    }

    modifier isPoolNotClosed(uint256 index) {
        require(pools[index].closeAt > now, "this pool is closed");
        _;
    }

    modifier isPoolExist(uint256 index) {
        require(index < pools.length, "this pool does not exist");
        _;
    }

    modifier isPoolStarted(uint256 index) {
        require(startAt[index] <= now, "this pool is not started yet");
        _;
    }

    function setPromoToken(address _promoToken, uint256 _fee)
        external
        governance
        returns (bool)
    {
        promoTokenList[_promoToken] = _fee;
        return true;
    }

    function getTokenRate(address _promoToken) external view returns (uint256) {
        uint256 rate = fee;
        if (promoTokenList[_promoToken] != 0) {
            rate = promoTokenList[_promoToken];
        }
        return rate;
    }

    function transferERC20(
        address _erc20Address,
        address _to,
        uint256 _amount
    ) external governance returns (bool) {
        try IERC20(_erc20Address).transfer(_to, _amount) {
            return true;
        } catch Error(string memory) {
            return false;
        }
    }

    function transferERC721(
        address _erc721Address,
        address _to,
        uint256 _tokenId
    ) external governance returns (bool) {
        try
            IERC721(_erc721Address).safeTransferFrom(
                address(this),
                _to,
                _tokenId
            )
        {
            return true;
        } catch Error(string memory) {
            return false;
        }
    }
}
