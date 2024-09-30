// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import 'forge-std/src/Script.sol';
import '../contracts/staking/StakingNFT.sol';

contract StakingNFTDeploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
        vm.startBroadcast(deployerPrivateKey);

        address collection = 0xd5ce3bCd228F9f098898DDcc9cbcc57657cdB2Dc;
        address validator = msg.sender;
        address token = 0x20516d48337377268b4e6b885b5d6cb39eee65c9;
        StakingNFT staking = new StakingNFT(collection, validator, token);
        console.log('StakingNFT address: ', address(staking));
        vm.stopBroadcast();
    }
}

// command terminal
// source .env
// forge script --chain sepolia script/Staking.deploy.sol:StakingNFTDeploy --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
