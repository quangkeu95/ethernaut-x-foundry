// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../BaseLevel.sol";
import "./Reentrance.sol";

contract ReentranceFactory is Level {
    uint256 public insertCoin = 1 ether;

    function createInstance(address _player) public payable override returns (address) {
        _player;
        require(msg.value >= insertCoin);
        Reentrance instance = new Reentrance();
        require(address(this).balance >= insertCoin);
        payable(address(instance)).transfer(insertCoin);
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) public override returns (bool) {
        _player;
        Reentrance instance = Reentrance(_instance);
        return address(instance).balance == 0;
    }

    receive() external payable { }
}
