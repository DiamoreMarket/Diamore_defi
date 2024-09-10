pragma solidity ^0.8.20;
import 'node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol';

interface INFTify721 is IERC721 {
     function allowTransfer(uint256 tokenId, bool value) external;
}
