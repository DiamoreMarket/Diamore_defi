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

// command terminal
// source .env
// forge script --chain sepolia script/Staking.deploy.sol:StakingNFTDeploy --rpc-url $SEPOLIA_RPC_URL --broadcast --verify --private-key $PRIVATE_KEY_MAIN -vvvv

// forge script script/Staking.deploy.sol:StakingNFTDeploy  --chain-id 1 --rpc-url $MAINNET_RPC_URL --broadcast --verify -vvvv

// forge script script/Staking.deploy.sol:StakingNFTDeploy --slow --verify --verifier-url https://virtual.mainnet.rpc.tenderly.co/b3e692b5-7009-4ec4-b0c3-b6e0c16e6753/verify/etherscan --rpc-url https://virtual.mainnet.rpc.tenderly.co/b3e692b5-7009-4ec4-b0c3-b6e0c16e6753 --private-key 0xb20e0059eed7dedc2166687e9afa1621d97d591dbe87d8a7c671b89ffdf9bd37 --etherscan-api-key Td2sKKcQ62L1PcFliIFhDyOILi1Rwi4Q --broadcast

//  0x20516d48337377268b4e6b885b5d6cb39eee65c9
//   StakingNFT address:  0x072eDaF9c259303fb7cccBE9c6912e15b4552999

// forge verify-contract 0x91498663C306E700a73d2F4F9F4528Bb448A2742 StakingNFT --etherscan-api-key $ETHERSCAN_API_KEY --rpc-url $MAINNET_RPC_URL --constructor-args 0x20b7287a72c68602a6b9e3b7f0d8ac0e1b02d2b4000000000000000000000000f859e9f0dc674d5a02616006ce9bdfdedd1a8876000000000000000000000000dac17f958d2ee523a2206206994597c13d831ec7

// forge verify-contract \
//     --chain-id 1 \
//     --num-of-optimizations 10000 \
//     --constructor-args 0x00000000000000000000000020b7287a72c68602a6b9e3b7f0d8ac0e1b02d2b4000000000000000000000000f859e9f0dc674d5a02616006ce9bdfdedd1a8876000000000000000000000000dac17f958d2ee523a2206206994597c13d831ec7 \
//     --rpc-url $MAINNET_RPC_URL \
//     --etherscan-api-key $ETHERSCAN_API_KEY \
//     --compiler-version 0.8.26+commit.8a97fa7a \
//     0x91498663C306E700a73d2F4F9F4528Bb448A2742 \
//     StakingNFT \
// --watch
