// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/src/Script.sol";
import "../contracts/staking/Treasure.sol";

contract TreasureNFTDeploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // address admin = msg.sender;
        // address collection = 0x20B7287A72c68602a6b9E3b7F0D8AC0E1b02d2b4;
        // address stakingAddress = ;
        // address token = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        // Treasure treasure = new Treasure(admin, collection, stakingAddress, token);
        // console.log('Treasure address: ', address(treasure));
        // vm.stopBroadcast();
    }
}

// command terminal
// source .env
// forge script --chain sepolia script/Treasure.deploy.sol:TreasureNFTDeploy --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

// forge script --chain mainnet script/Treasure.deploy.sol:TreasureNFTDeploy --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

// forge script script/Treasure.deploy.sol:TreasureNFTDeploy --slow --verify --verifier-url https://virtual.mainnet.rpc.tenderly.co/b3e692b5-7009-4ec4-b0c3-b6e0c16e6753/verify/etherscan --rpc-url https://virtual.mainnet.rpc.tenderly.co/b3e692b5-7009-4ec4-b0c3-b6e0c16e6753 --private-key 0xb20e0059eed7dedc2166687e9afa1621d97d591dbe87d8a7c671b89ffdf9bd37 --etherscan-api-key Td2sKKcQ62L1PcFliIFhDyOILi1Rwi4Q --broadcast

//  Treasure address:  0x4afc0b70Ed4De8a139c7CC143ed664A0E22b1Ec8
