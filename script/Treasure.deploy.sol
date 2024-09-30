// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import 'forge-std/src/Script.sol';
import '../contracts/staking/Treasure.sol';

contract TreasureNFTDeploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
        vm.startBroadcast(deployerPrivateKey);

        address admin = msg.sender;
        address collection = 0xd5ce3bCd228F9f098898DDcc9cbcc57657cdB2Dc;
        address stakingAddress = 0x0ED0D3457Fb2D8672aFed7eb92fE61CB2B541F74;
        address token = 0x20516d48337377268b4e6b885b5d6cb39eee65c9;
        Treasure treasure = new Treasure(admin, collection, stakingAddress, token);
        console.log('Treasure address: ', address(treasure));
        vm.stopBroadcast();
    }
}

// command terminal
// source .env
// forge script --chain sepolia script/Treasure.deploy.sol:TreasureNFTDeploy --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
