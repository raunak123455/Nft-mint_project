// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract RoboPunksNFT is ERC721, Ownable {
    uint256 public mintPrice;
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public maxPerWallet;
    bool public isPublicMintEnabled;
    string internal baseTokenURI;
    address payable public withdrawWallet;
    mapping(address => uint256) public walletMints;

    constructor() payable ERC721('RoboPunks', 'RP') {
        mintPrice = 0.02 ether;
        totalSupply = 0;
        maxSupply = 1000;
        maxPerWallet = 3;
        //withdrawalAddress = "0x78f4FCA81553b6D3c159AA978e8b914a1Ae75cAA";
    }

    function  setIsPublicMintEnabled(bool _isPublicMintEnabled) external onlyOwner {
        isPublicMintEnabled = _isPublicMintEnabled;
    }

    function setBaseTokenURI(string calldata _baseTokenURI) external onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function tokenURI(uint256 _tokenID) public view override returns (string memory) {
        require(_exists(_tokenID), 'Token does not exist!');
        return string(abi.encodePacked(baseTokenURI, Strings.toString(_tokenID), ".json"));
    }

    function withdraw() external onlyOwner {
        (bool success, ) = withdrawWallet.call{ value: address(this).balance }('');
        require(success, 'withdraw failed');
    }

    function mint(uint256 _quantity) public payable {
        require(isPublicMintEnabled, 'Minting not enabled');
        require(msg.value == _quantity * mintPrice, 'Wrong Mint Value');
        require(totalSupply + _quantity <= maxSupply, 'Sold Out');
        require(walletMints[msg.sender] + _quantity <= maxPerWallet, 'Exceeded Max Wallet');

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 newTokenId = totalSupply + 1;
            totalSupply++;
            _safeMint(msg.sender, newTokenId);
        }
    }
}