pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Governable.sol";

contract FreeExhibitionHallNFT is Governable, ERC721 {

  event Mint(address indexed owner, uint256 indexed tokenId);

  uint256 private _counter;


  mapping(address => bool) public artist;

  modifier onlyArtist() {
    require(artist[msg.sender], "only artist");
    _;
  }

  constructor (
    string memory name, 
    string memory symbol, 
    string memory baseURI
  ) ERC721(name, symbol) public {
    _setBaseURI(baseURI);
    super.initialize(msg.sender);
  }

  function setBaseURI(string memory baseURI) external governance returns (bool) {
      _setBaseURI(baseURI);
  }

  function setTokenURI(uint256 tokenId, string memory _tokenURI) external governance returns (bool) {
      _setTokenURI(tokenId, _tokenURI);
  }

  function mint() public onlyArtist {
    _counter += 1;
    _mint(msg.sender, _counter);
    emit Mint(msg.sender, _counter);
  }

  function setArtist(address _artist, bool enabled) external governance returns (bool) {
        artist[_artist] = enabled;
        return true;
    }

}
