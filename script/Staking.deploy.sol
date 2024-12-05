// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/src/Script.sol";
import "../contracts/staking/StakingNFT.sol";

contract StakingNFTDeploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address collection = 0x20B7287A72c68602a6b9E3b7F0D8AC0E1b02d2b4;
        address validator = 0xF859e9f0dC674D5A02616006CE9bdFDEDD1A8876;
        address token = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        StakingNFT staking = new StakingNFT(collection, validator, token);
        console.log("StakingNFT address: ", address(staking));
        vm.stopBroadcast();
    }
}