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
