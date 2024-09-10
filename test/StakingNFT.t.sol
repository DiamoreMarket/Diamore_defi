import {Test, console, Vm} from 'forge-std/src/Test.sol';
import {VmSafe} from 'node_modules/forge-std/src/Vm.sol';
import {IERC20, SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {INFTify721} from 'contracts/mock/INFTify721.sol';
import {StakingNFT, IStakingNFT} from 'contracts/staking/StakingNFT.sol';

contract StakingNFTTest is Test {
    using SafeERC20 for IERC20;

    address treasure = makeAddr('treasure');
    address admin = makeAddr('admin');
    address deployer = makeAddr('deployer');
    VmSafe.Wallet validator = vm.createWallet('validator');
    VmSafe.Wallet badValidator = vm.createWallet('badValidator');

    address holder = 0x693a10f33974FdA182e34d0d179c5247874897A3;
    address controller = 0x25f2F80D9a45B641bEf25342A1B2a0Ae48F78539;
    IERC20 constant usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    INFTify721 collection = INFTify721(0x20B7287A72c68602a6b9E3b7F0D8AC0E1b02d2b4);
    StakingNFT staking;

    function setUp() public {
        uint256 forkId = vm.createFork(vm.envString('ALCHEMY_RPC'), 20008600);
        vm.selectFork(forkId);

        vm.startPrank(deployer);

        staking = new StakingNFT(address(collection), validator.addr, address(usdt), treasure);
        vm.stopPrank();
        deal(address(usdt), treasure, 10000e6);

        vm.startPrank(treasure);
        IERC20(usdt).forceApprove(address(staking), 10000e6);
        vm.stopPrank();
    }

    function test_stake() public {
        uint256 tokenId = 10475930865216964207240693939129450693466902451350659726041528447710005539241;

        vm.startPrank(controller);
        collection.allowTransfer(tokenId, true);
        vm.stopPrank();

        vm.startPrank(holder);

        vm.expectRevert(bytes('ERC721: caller is not token owner or approved'));
        staking.stake(tokenId, IStakingNFT.LockPeriod.ThreeMonths);

        _stake(tokenId);

        IStakingNFT.NFTInfo memory info = staking.getInfoNFT(tokenId);

        assertEq(info.owner, holder);
        assertEq(info.timeUnlock, staking.THREE_MONTH() + block.timestamp);
        assertEq(info.rewardReceived, 0);
        assertEq(collection.balanceOf(holder), 0);

        vm.stopPrank();
    }

    function test_sign() public {
        uint256 tokenId = 10475930865216964207240693939129450693466902451350659726041528447710005539241;
        IStakingNFT.Message memory message = IStakingNFT.Message({tokenId: tokenId, amount: 100, nonce: 0});

        IStakingNFT.Vrs memory vrs = _sign(message, validator);
        address _recoverAddress = staking.recoverSign(vrs, message);

        assertEq(_recoverAddress, validator.addr);

        vrs = _sign(message, badValidator);
        _recoverAddress = staking.recoverSign(vrs, message);
        assertNotEq(_recoverAddress, validator.addr);
    }

    function test_claim() public {
        uint256 tokenId = 10475930865216964207240693939129450693466902451350659726041528447710005539241;

        _allowTransfer(tokenId);
        _stake(tokenId);

        IStakingNFT.Message memory message = IStakingNFT.Message({tokenId: tokenId, amount: 100e6, nonce: 0});
        IStakingNFT.Vrs memory vrs = _sign(message, badValidator);

        vm.expectRevert(abi.encodeWithSelector(IStakingNFT.InvalidSignature.selector));
        staking.claim(vrs, message);

        vrs = _sign(message, validator);
        vm.expectRevert(abi.encodeWithSelector(IStakingNFT.NotOwner.selector));
        staking.claim(vrs, message);

        vm.startPrank(holder);
        staking.claim(vrs, message);

        vm.expectRevert(abi.encodeWithSelector(IStakingNFT.HashUsed.selector));
        staking.claim(vrs, message);

        IStakingNFT.NFTInfo memory info = staking.getInfoNFT(tokenId);
        assertEq(info.rewardReceived, 100e6);
        assertEq(IERC20(usdt).balanceOf(holder), message.amount);

        message = IStakingNFT.Message({tokenId: tokenId, amount: 100e6, nonce: 1});
        vrs = _sign(message, validator);
        staking.claim(vrs, message);
        info = staking.getInfoNFT(tokenId);
        assertEq(info.rewardReceived, 200e6);
    }

    function test_unstake() public {
        uint256 tokenId = 10475930865216964207240693939129450693466902451350659726041528447710005539241;

        _allowTransfer(tokenId);
        _stake(tokenId);

        IStakingNFT.Message memory message = IStakingNFT.Message({tokenId: tokenId, amount: 100e6, nonce: 0});
        IStakingNFT.Vrs memory vrs = _sign(message, validator);

        vm.startPrank(holder);
        IStakingNFT.NFTInfo memory info = staking.getInfoNFT(tokenId);

        vm.expectRevert(abi.encodeWithSelector(IStakingNFT.NotReadyToUnstake.selector, info.timeUnlock));
        staking.unstake(vrs, message);

        vm.warp(block.timestamp + 100 days);
        staking.unstake(vrs, message);

        assertEq(IERC20(usdt).balanceOf(holder), message.amount);
        assertEq(collection.balanceOf(holder), 1);

        message = IStakingNFT.Message({tokenId: tokenId, amount: 100e6, nonce: 1});
        vrs = _sign(message, validator);
        vm.expectRevert(abi.encodeWithSelector(IStakingNFT.NotOwner.selector));
        staking.unstake(vrs, message);

        vm.expectRevert(abi.encodeWithSelector(IStakingNFT.NotOwner.selector));
        staking.claim(vrs, message);

        vm.stopPrank();

        info = staking.getInfoNFT(tokenId);
        assertEq(info.timeUnlock, 0);
        assertEq(info.rewardReceived, 0);
        assertEq(info.owner, address(0));
    }

    function test_admin_functions() public {
        vm.startPrank(deployer);
        staking.grantRole(staking.ADMIN_ROLE(), admin);
        vm.stopPrank();

        vm.startPrank(admin);
        staking.setTreasure(address(0));
        assertEq(staking.treasure(), address(0));
        vm.stopPrank();

        uint256 tokenId = 10475930865216964207240693939129450693466902451350659726041528447710005539241;
        _allowTransfer(tokenId);
        _stake(tokenId);
        assertEq(collection.balanceOf(address(staking)), 1);

        vm.startPrank(admin);
        staking.withdraw(tokenId, admin);
        assertEq(collection.balanceOf(admin), 1);

        collection.approve(address(staking), tokenId);
        staking.refund(tokenId);
        assertEq(collection.balanceOf(address(staking)), 1);
        assertEq(collection.balanceOf(admin), 0);

        vm.stopPrank();
    }

    function _sign(
        IStakingNFT.Message memory message,
        VmSafe.Wallet memory signer
    ) internal returns (IStakingNFT.Vrs memory vrs) {
        bytes32 digest = staking.hashTypedDataV4(message);
        (vrs.v, vrs.r, vrs.s) = vm.sign(signer, digest);
    }

    function _allowTransfer(uint256 tokenId) internal {
        vm.startPrank(controller);
        collection.allowTransfer(tokenId, true);
        vm.stopPrank();
    }

    function _stake(uint256 tokenId) internal {
        vm.startPrank(holder);
        collection.approve(address(staking), tokenId);
        staking.stake(tokenId, IStakingNFT.LockPeriod.ThreeMonths);
        vm.stopPrank();
    }
}
