pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Governable.sol";

contract DFA1155NFT is Governable, ERC1155 {
  using Strings for uint256;

  event Mint(address indexed owner, uint256 indexed tokenId, uint256 amount);

  uint256 private _counter;
  string public name;
  string public symbol;
  string public baseURI;


  mapping(address => bool) public artist;

  modifier onlyArtist() {
    require(artist[msg.sender], "only artist");
    _;
  }

  constructor (
    string memory _name, 
    string memory _symbol, 
    string memory _baseURI
  ) ERC1155(baseURI) public {
    name = _name;
    symbol = _symbol;
    baseURI  = _baseURI;
    _setURI(_baseURI);
    super.initialize(msg.sender);
  }

  function setURI(string memory _baseURI) external governance returns (bool) {
      baseURI = _baseURI;
      _setURI(_baseURI);
  }

  function uri(uint256 tokenId) public view virtual override returns (string memory) {
      return string(abi.encodePacked(baseURI, tokenId.toString()));
  }

  function mint(uint256 amount,bytes calldata data) public onlyArtist {
    _counter += 1;
    _mint(msg.sender, _counter, amount, data);
    emit Mint(msg.sender, _counter, amount);
  }

  function setArtist(address _artist, bool enabled) external governance returns (bool) {
        artist[_artist] = enabled;
        return true;
    }

}
