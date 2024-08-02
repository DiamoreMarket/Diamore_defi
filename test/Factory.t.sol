// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console, Vm} from 'forge-std/src/Test.sol';
import {IERC20, ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {Factory} from 'contracts/Factory.sol';
import {DiamoreToken} from 'contracts/DiamoreToken.sol';
import {IAccessControl} from '@openzeppelin/contracts/access/IAccessControl.sol';

contract AdapterTest is Test {
    ERC20 constant usdt = ERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    ERC20 constant dai = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    address user = makeAddr('user');
    address user2 = makeAddr('user2');
    address admin = makeAddr('admin');
    address deployer = makeAddr('deployer');

    string internal _prefixName = 'Diamore: ';
    string internal _prefixSymbol = 'dmr';

    Factory factory;

    function setUp() public {
        uint256 forkId = vm.createFork(vm.envString('ALCHEMY_RPC'), 20008600);
        vm.selectFork(forkId);

        vm.startPrank(deployer);

        factory = new Factory(_prefixName, _prefixSymbol);
        uint256 amount = 100e18;
        deal(user, amount);
        deal(address(usdt), user, amount);
        deal(address(dai), user, amount);
        assertEq(usdt.balanceOf(user), amount);
        assertEq(dai.balanceOf(user), amount);
        factory.grantRole(factory.ADMIN_ROLE(), admin);

        vm.stopPrank();
    }

    function test_create() public {
        vm.startPrank(user);

        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, user, factory.ADMIN_ROLE())
        );
        factory.createToken(address(usdt));
        vm.stopPrank();

        vm.startPrank(admin);
        address dmrUsdt = factory.getContractAddress(address(usdt));
        factory.createToken(address(usdt));
        address dmrDai = factory.getContractAddress(address(dai));
        factory.createToken(address(dai));
        address[] memory list = factory.getTokenList();
        assertEq(list[0], dmrUsdt);
        assertEq(list[1], dmrDai);
        vm.stopPrank();
    }

    function test_token() public {
        vm.startPrank(admin);
        DiamoreToken dmrDai = DiamoreToken(factory.createToken(address(dai)));
        console.log(address(dmrDai));
        assertEq(dmrDai.decimals(), dai.decimals());
        assertEq(string(abi.encodePacked(_prefixName, dai.name())), dmrDai.name());
        assertEq(string(abi.encodePacked(_prefixSymbol, dai.symbol())), dmrDai.symbol());
        assertEq(dmrDai.totalSupply(), 0);
        assertEq(dmrDai.originalToken(), address(dai));

        vm.stopPrank();

        vm.startPrank(user);
        uint256 amount = 100e18;
        dai.approve(address(dmrDai), amount);
        dmrDai.exchange(amount);
        assertEq(dmrDai.balanceOf(user), amount);
        assertEq(dai.balanceOf(address(dmrDai)), amount);

        dmrDai.reverseExchange(10e18);
        assertEq(dmrDai.balanceOf(user), 90e18);
        assertEq(dai.balanceOf(address(dmrDai)), 90e18);
        vm.stopPrank();
    }
}