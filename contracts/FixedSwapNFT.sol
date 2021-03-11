// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC721/IERC721Receiver.sol";
import "./Governable.sol";
import "./interfaces/IERC1155.sol";

contract FixedSwapNFT is Configurable, IERC721Receiver {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    uint    internal constant TypeErc721            = 0;
    uint    internal constant TypeErc1155           = 1;

    struct Pool {
        // address of pool creator
        address payable creator;
        // pool name
        string name;
        // address of sell token
        address token0;
        // address of buy token
        address token1;
        // token id of token0
        uint tokenId;
        // total amount of token0
        uint amountTotal0;
        // total amount of token1
        uint amountTotal1;
        // the timestamp in seconds the pool will be closed
        uint closeAt;
        // NFT token type
        uint nftType;
    }

    Pool[] public pools;

    // creator address => pool index + 1. if the result is 0, the account don't create any pool.
    mapping(address => uint) public myCreatedP;
    // name => pool index + 1
    mapping(string => uint) public myNameP;

    // pool index => a flag that if creator is claimed the pool
    mapping(uint => bool) public creatorClaimedP;
    mapping(uint => bool) public swappedP;

    // check if token0 in whitelist
    bool public checkToken0;
    // token0 address => true or false
    mapping(address => bool) public token0List;

    event Created(Pool pool, uint index);
    event Swapped(address sender, uint index);
    event Claimed(address sender, uint index);

    function initialize(address _governor) public override initializer {
        require(msg.sender == governor || governor == address(0), "invalid governor");
        governor = _governor;
    }

    function createErc721(
        // name of the pool
        string memory name,
        // address of token0
        address token0,
        // address of token1
        address token1,
        // token id of token0
        uint tokenId,
        // total amount of token1
        uint amountTotal1,
        // duration time
        uint duration
    ) external payable {
        if (checkToken0) {
            require(token0List[token0], "invalid token0");
        }
        uint amountTotal0 = 1;
        _create(
            name, token0, token1, tokenId, amountTotal0, amountTotal1,
            duration, TypeErc721
        );
    }

    function createErc1155(
        // name of the pool
        string memory name,
        // address of token0
        address token0,
        // address of token1
        address token1,
        // token id of token0
        uint tokenId,
        // total amount of token0
        uint amountTotal0,
        // total amount of token1
        uint amountTotal1,
        // duration time
        uint duration
    ) external payable {
        if (checkToken0) {
            require(token0List[token0], "invalid token0");
        }
        _create(
            name, token0, token1, tokenId, amountTotal0, amountTotal1,
            duration, TypeErc1155
        );
    }

    function _create(
        string memory name,
        address token0,
        address token1,
        uint tokenId,
        uint amountTotal0,
        uint amountTotal1,
        uint duration,
        uint nftType
    ) private
        isPoolNotCreate(msg.sender)
        nameNotBeenToken(name)
    {
        require(amountTotal1 != 0, "the value of amountTotal1 is zero.");
        require(duration != 0, "the value of duration is zero.");
        require(bytes(name).length <= 15, "the length of name is too long");

        // transfer tokenId of token0 to this contract
        if (nftType == TypeErc721) {
            require(amountTotal0 == 1, "invalid amountTotal0");
            IERC721(token0).safeTransferFrom(msg.sender, address(this), tokenId);
        } else {
            require(amountTotal0 != 0, "invalid amountTotal0");
            IERC1155(token0).safeTransferFrom(msg.sender, address(this), tokenId, amountTotal0, "");
        }

        // creator pool
        Pool memory pool;
        pool.creator = msg.sender;
        pool.name = name;
        pool.token0 = token0;
        pool.token1 = token1;
        pool.tokenId = tokenId;
        pool.amountTotal0 = amountTotal0;
        pool.amountTotal1 = amountTotal1;
        pool.closeAt = now.add(duration);
        pool.nftType = nftType;

        uint index = pools.length;

        pools.push(pool);
        myCreatedP[msg.sender] = pools.length;
        myNameP[name] = pools.length;

        emit Created(pool, index);
    }

    function swap(uint index) external payable
        isPoolExist(index)
        isPoolNotClosed(index)
        isPoolNotSwap(index)
    {
        Pool storage pool = pools[index];
        // mark pool is swapped
        swappedP[index] = true;

        // transfer amount of token1 to creator
        if (pool.token1 == address(0)) {
            require(pool.amountTotal1 == msg.value, "invalid ETH amount");
            // transfer ETH to creator
            pool.creator.transfer(pool.amountTotal1);
        } else {
            IERC20(pool.token1).safeTransferFrom(msg.sender, address(this), pool.amountTotal1);
            IERC20(pool.token1).safeApprove(address(this), 0);
            // transfer token1 to creator
            IERC20(pool.token1).safeTransfer(pool.creator, pool.amountTotal1);
        }

        // transfer tokenId of token0 to sender
        if (pool.nftType == TypeErc721) {
            IERC721(pool.token0).safeTransferFrom(address(this), msg.sender, pool.tokenId);
        } else {
            IERC1155(pool.token0).safeTransferFrom(address(this), msg.sender, pool.tokenId, pool.amountTotal0, "");
        }

        emit Swapped(msg.sender, index);
    }

    function creatorClaim(uint index) external
        isPoolExist(index)
        isPoolClosed(index)
        isPoolNotSwap(index)
    {
        require(isCreator(msg.sender, index), "sender is not pool creator");
        require(!creatorClaimedP[index], "creator has claimed this pool");
        creatorClaimedP[index] = true;

        // remove ownership of this pool from creator
        delete myCreatedP[msg.sender];

        Pool memory pool = pools[index];
        if (pool.nftType == TypeErc721) {
            IERC721(pool.token0).safeTransferFrom(address(this), pool.creator, pool.tokenId);
        } else {
            IERC1155(pool.token0).safeTransferFrom(address(this), pool.creator, pool.tokenId, pool.amountTotal0, "");
        }

        emit Claimed(msg.sender, index);
    }

    function transferGovernor(address _governor) external {
        require(msg.sender == governor || governor == address(0), "invalid governor");
        governor = _governor;
    }

    function isCreator(address target, uint index) internal view returns (bool) {
        if (pools[index].creator == target) {
            return true;
        }
        return false;
    }

    function getPoolCount() external view returns (uint) {
        return pools.length;
    }

    function onERC721Received(address, address, uint, bytes calldata) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(address, address, uint, uint, bytes calldata) external returns(bytes4) {
        return this.onERC1155Received.selector;
    }

    modifier isPoolClosed(uint index) {
        require(pools[index].closeAt <= now, "this pool is not closed");
        _;
    }

    modifier isPoolNotClosed(uint index) {
        require(pools[index].closeAt > now, "this pool is closed");
        _;
    }

    modifier isPoolNotSwap(uint index) {
        require(!swappedP[index], "this pool is swapped");
        _;
    }

    modifier isPoolNotCreate(address creator) {
        if (myCreatedP[creator] > 0) {
            if (swappedP[myCreatedP[creator]-1]) {
                delete myCreatedP[creator];
            } else {
                revert("a pool has created by this address");
            }
        }
        _;
    }

    modifier isPoolExist(uint index) {
        require(index < pools.length, "this pool does not exist");
        _;
    }

    modifier nameNotBeenToken(string memory name) {
        // check if someone has take this name
        if (myNameP[name] > 0) {
            uint index = myNameP[name] - 1;
            if ((myCreatedP[pools[index].creator] > 0) && (pools[index].closeAt > now)) {
                revert("a live pool has been created by this name");
            }
        }
        _;
    }
}
