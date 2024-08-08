// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import 'forge-std/src/Script.sol';
import {Factory} from 'contracts/Factory.sol';

contract FactoryDeploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
        console.log('Deployer private key: ', deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        Factory factory = new Factory();
        console.log('Factory address: ', address(factory));
        vm.stopBroadcast();
    }
}

// command terminal
// forge script --chain sepolia script/Factory.deploy.sol:FactoryDeploy --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
