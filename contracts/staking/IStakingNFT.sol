// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStakingNFT {
    struct NFTInfo {
        address owner;
        uint256 timeUnlock;
    }

    struct Message {
        address account;
        uint256 amount;
        uint256 nonce;
        uint256 timeExpire;
    }

    struct Vrs {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    enum LockPeriod {
        ThreeMonths,
        SixMonths,
        OneYear
    }

    event Claimed(address owner, uint256 amount, Vrs vrs);
    event Unstaked(address owner, uint256 tokenId);
    event Staked(address owner, uint256 tokenId, uint256 timeUnlock, LockPeriod lock);

    error NotOwner();
    error HashUsed();
    error InvalidSignature();
    error NotReadyToUnstake(uint256 timeUnlock);
    error Expired(uint256 timeExpire);

    function setTreasure(address newTreasure) external;

    function stake(uint256 tokenId, LockPeriod lock) external;

    function unstake(uint256 tokenId) external;

    function claim(Vrs calldata vrs, Message calldata message) external;

    function getInfoNFT(uint256 tokenId) external view returns (NFTInfo memory);

    function recoverSign(Vrs calldata vrs, Message calldata message) external view returns (address _recoverAddress);

    function hashTypedDataV4(Message calldata message) external view returns (bytes32 digest);

    function getVrsStatus(Message calldata message) external view returns (bool);
}
