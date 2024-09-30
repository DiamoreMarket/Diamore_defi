// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import 'forge-std/src/Script.sol';
import 'contracts/nft/NFTify721.sol';

contract NftfyDeploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
        vm.startBroadcast(deployerPrivateKey);

        NFTify721 nft = new NFTify721(
            'White Natural Diamonds',
            'WND',
            'https://metadata.nftify.network/ipfs/',
            0x25f2F80D9a45B641bEf25342A1B2a0Ae48F78539
        );
        console.log('NFTify721 address: ', address(nft));
        vm.stopBroadcast();
    }
}

// command terminal
// source .env
// forge script --chain sepolia script/Nftfy.deploy.sol:NftfyDeploy --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
