pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { MagicNum } from "src/MagicNum/MagicNum.sol";
import { MagicNumFactory } from "src/MagicNum/MagicNumFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";
import "forge-std/console.sol";

contract MagicNumTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testMagicNumHack() external {
        // level setup
        MagicNumFactory factory = new MagicNumFactory();
        ethernaut.registerLevel(factory);

        vm.startPrank(me);
        address levelAddress = ethernaut.createLevelInstance(factory);
        MagicNum magicNum = MagicNum(payable(levelAddress));

        // we want to return 32bytes result with value 0x2a from the solver
        // and the requirement for code size is maximum 10 bytes
        // we will be using opcodes PUSH1, MSTORE and RETURN
        // PUSH1 2a -- 602a -- Push value 2a to the stack
        // PUSH1 80 -- 6080 -- Push value 80 to the stack
        // MSTORE -- 52 -- Store value 0x2a to memory address 0x80
        // PUSH1 20 -- 6020
        // PUSH1 80 -- 6080
        // RETURN -- f3 -- Return 32bytes data from memory address 0x80
        // so the final runtime bytecode is 602a60805260206080f3

        /// we need to create the init bytecode, which will return the runtime bytecode from the it
        // PUSH1 0a -- 600a -- Runtime code size
        // PUSH1 0c -- 600c -- Runtime code start size
        // PUSH1 00 -- 6000 -- Memory address to copy to
        // CODECOPY -- 39
        // PUSH1 0a -- 600a
        // PUSH1 00 -- 6000
        // RETURN - f3
        // so the init bytecode is 600a600c600039600a6000f3602a60805260206080f3

        bytes memory code = "\x60\x0a\x60\x0c\x60\x00\x39\x60\x0a\x60\x00\xf3\x60\x2a\x60\x80\x52\x60\x20\x60\x80\xf3";
        address solver;
        assembly {
            solver := create(0, add(code, 0x20), mload(code))
            if iszero(extcodesize(solver)) { revert(0, 0) }
        }
        magicNum.setSolver(solver);

        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
