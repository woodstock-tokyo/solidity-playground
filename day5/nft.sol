// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;

    constructor(address marketplaceAddress) ERC721("Demo NFTs", "DEMONFT") {
        contractAddress = marketplaceAddress;
    }

    // token uri: https://ipfs.infura.io/ipfs/QmPgMDEVDSFbQcCkMBjfef99sBjVRJL7vaG9V1dnp1uEFA for example
    function createToken(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }
}
