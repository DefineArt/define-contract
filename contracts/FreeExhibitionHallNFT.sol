pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract FreeExhibitionHallNFT is ERC721 {

  event Mint(address indexed owner, uint256 indexed tokenId);

  uint256 private _counter;

  constructor (
    string memory name, 
    string memory symbol, 
    string memory baseURI
  ) ERC721(name, symbol) public {
    _setBaseURI(baseURI);
  }

  function mint() public {
    _counter += 1;
    _mint(msg.sender, _counter);
    emit Mint(msg.sender, _counter);
  }

}
