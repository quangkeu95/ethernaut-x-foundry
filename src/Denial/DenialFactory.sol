// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../BaseLevel.sol";
import "./Denial.sol";

contract DenialFactory is Level {
    uint256 public initialDeposit = 0.001 ether;

    function createInstance(address _player) public payable override returns (address) {
        _player;
        require(msg.value >= initialDeposit);
        Denial instance = new Denial();
        (bool result,) = address(instance).call{ value: msg.value }("");
        require(result);
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) public override returns (bool) {
        _player;
        Denial instance = Denial(_instance);
        if (address(instance).balance <= 100 wei) {
            // cheating otherwise
            return false;
        }
        // fix the gas limit for this call
        (bool result,) = address(instance).call{ gas: 1_000_000 }(abi.encodeWithSignature("withdraw()")); // Must revert
        return !result;
    }

    receive() external payable { }
}
