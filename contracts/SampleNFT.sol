// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC721Permit.sol";

contract SampleNFT is ERC721Permit, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public constant MAX_SUPPLY = 10;
    string private _baseTokenURI;

    constructor(string memory baseTokenURI) ERC721Permit("SampleNFT", "SNFT") {
        _baseTokenURI = baseTokenURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, ERC721Permit)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Permit) {
        super._transfer(from, to, tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
        require(totalSupply() <= MAX_SUPPLY);
    }

    function mint(address to) public {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(to, newTokenId);
    }

    function safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        uint256 deadline,
        bytes memory signature
    ) external {
        _permit(msg.sender, tokenId, deadline, signature);
        safeTransferFrom(from, to, tokenId);
    }
}
