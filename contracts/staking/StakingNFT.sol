// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
// import {ERC721Holder} from '@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {IERC20, SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {EIP712} from '@openzeppelin/contracts/utils/cryptography/EIP712.sol';
import {ECDSA} from '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import {IStakingNFT} from './/IStakingNFT.sol';

contract StakingNFT is EIP712, AccessControl, IStakingNFT {
    using SafeERC20 for IERC20;
    bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');
    bytes32 public constant VALIDATOR_ROLE = keccak256('VALIDATOR_ROLE');

    uint256 public constant THREE_MONTH = 90 days;
    uint256 public constant SIX_MONTH = 180 days;
    uint256 public constant ONE_YEAR = 365 days;

    address public collection;
    address public tokenReward;
    address public treasure;

    mapping(uint256 => NFTInfo) internal _nftInfoById;
    mapping(bytes32 => bool) internal _isHashUsed;

    event TreasureUpdated(address newTreasure);

    constructor(address collectionNFT, address validator, address rewardToken) EIP712('StakingNFT', '1.0') {
        collection = collectionNFT;
        tokenReward = rewardToken;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(VALIDATOR_ROLE, validator);
    }

    function setTreasure(address newTreasure) external override onlyRole(ADMIN_ROLE) {
        _setTreasure(newTreasure);
    }

    function stake(uint256 tokenId, LockPeriod lock) external override {
        IERC721(collection).safeTransferFrom(msg.sender, treasure, tokenId);
        _nftInfoById[tokenId] = NFTInfo({owner: msg.sender, timeUnlock: _choiceLockPeriod(lock)});

        emit Staked(msg.sender, tokenId);
    }

    function unstake(uint256 tokenId) external override {
        if (msg.sender != _nftInfoById[tokenId].owner) {
            revert NotOwner();
        }
        if (_nftInfoById[tokenId].timeUnlock > block.timestamp) {
            revert NotReadyToUnstake(_nftInfoById[tokenId].timeUnlock);
        }

        IERC721(collection).safeTransferFrom(treasure, msg.sender, tokenId);
        delete (_nftInfoById[tokenId]);

        emit Unstaked(msg.sender, tokenId);
    }

    function getInfoNFT(uint256 tokenId) external view override returns (NFTInfo memory) {
        return _nftInfoById[tokenId];
    }

    function recoverSign(
        Vrs calldata vrs,
        Message calldata message
    ) external view override returns (address _recoverAddress) {
        (_recoverAddress, ) = _recoverMsg(vrs, message);

        return _recoverAddress;
    }

    function claim(Vrs calldata vrs, Message calldata message) public override {
        (address _recoverAddress, bytes32 digest) = _recoverMsg(vrs, message);
        if (_isHashUsed[digest]) {
            revert HashUsed();
        }
        if (!hasRole(VALIDATOR_ROLE, _recoverAddress)) {
            revert InvalidSignature();
        }
        if (msg.sender != _nftInfoById[message.tokenId].owner) {
            revert NotOwner();
        }
        _isHashUsed[digest] = true;

        IERC20(tokenReward).safeTransferFrom(treasure, _nftInfoById[message.tokenId].owner, message.amount);

        emit Claimed(msg.sender, message.tokenId, message.amount);
    }

    function hashTypedDataV4(Message calldata message) public view override returns (bytes32 digest) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256('Message(uint256 tokenId,uint256 amount,uint256 nonce)'),
                        message.tokenId,
                        message.amount,
                        message.nonce
                    )
                )
            );
    }

    function _setTreasure(address newTreasure) internal {
        treasure = newTreasure;

        emit TreasureUpdated(newTreasure);
    }

    function _recoverMsg(Vrs calldata vrs, Message calldata message) internal view returns (address, bytes32) {
        bytes32 digest = hashTypedDataV4(message);

        return (ECDSA.recover(digest, vrs.v, vrs.r, vrs.s), digest);
    }

    function _choiceLockPeriod(LockPeriod lock) internal view returns (uint256 res) {
        uint256 t = block.timestamp;
        assembly {
            switch lock
            case 0 {
                res := add(THREE_MONTH, t)
            }
            case 1 {
                res := add(SIX_MONTH, t)
            }
            case 2 {
                res := add(ONE_YEAR, t)
            }
        }
    }
}
