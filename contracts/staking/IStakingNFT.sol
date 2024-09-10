// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStakingNFT {
    struct NFTInfo {
        address owner;
        uint256 timeUnlock;
        uint256 rewardReceived;
    }
    struct Message {
        uint256 tokenId;
        uint256 amount;
        uint256 nonce;
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

    event Withdraw(address owner, uint256 tokenId);
    event Refund(address owner, uint256 tokenId);
    event Claimed(address owner, uint256 tokenId, uint256 amount);
    event Unstaked(address owner, uint256 tokenId);
    event Staked(address owner, uint256 tokenId);

    error NotOwner();
    error HashUsed();
    error InvalidSignature();
    error NotReadyToUnstake(uint256 timeUnlock);

    function withdraw(uint256 tokenId, address to) external;

    function setTreasure(address newTreasure) external;

    function refund(uint256 tokenId) external;

    function stake(uint256 tokenId, LockPeriod lock) external;

    function unstake(Vrs calldata vrs, Message calldata message) external;

    function claim(Vrs calldata vrs, Message calldata message) external;

    function getInfoNFT(uint256 tokenId) external view returns (NFTInfo memory);

    function recoverSign(Vrs calldata vrs, Message calldata message) external view returns (address _recoverAddress);

    function hashTypedDataV4(Message calldata message) external view returns (bytes32 digest);
}
