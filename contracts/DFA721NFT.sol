pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Governable.sol";

contract DFA721NFT is Governable, ERC721 {

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
    string memory addressStr = _toAsciiString(address(this));
    _setBaseURI(string(abi.encodePacked(baseURI, "0x", addressStr, "/")));
    artist[msg.sender] = true;
    super.initialize(msg.sender);
  }

  function _toAsciiString(address x) private pure returns (string memory) {
      bytes memory s = new bytes(40);
      for (uint256 i = 0; i < 20; i++) {
          bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8*(19 - i)))));
          bytes1 hi = bytes1(uint8(b) / 16);
          bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
          s[2*i] = _char(hi);
          s[2*i + 1] = _char(lo);
      }
      return string(s);
  }

  function _char(bytes1 b) private pure returns (bytes1 c) {
      if (uint8(b) < 10) {
          return bytes1(uint8(b) + 0x30);
      } else {
          return bytes1(uint8(b) + 0x57);
      }
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
