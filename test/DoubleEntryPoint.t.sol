pragma solidity >=0.8.19;

import { Test } from "forge-std/Test.sol";
import {
    DoubleEntryPoint,
    CryptoVault,
    LegacyToken,
    Forta,
    IDetectionBot,
    IForta
} from "src/DoubleEntryPoint/DoubleEntryPoint.sol";
import "forge-std/console2.sol";

interface IERC20 {
    function balanceOf(address user) external returns (uint256);
}

interface IVault {
    function sweptTokensRecipient() external returns (address);
}

contract DetectionBot is IDetectionBot {
    IVault public vault;
    IForta public forta;
    IERC20 public dbtToken;

    constructor(address _vault, address _dbtToken, address _forta) {
        vault = IVault(_vault);
        dbtToken = IERC20(_dbtToken);
        forta = IForta(_forta);
    }

    function handleTransaction(address user, bytes calldata msgData) external {
        address origSender;
        assembly {
            origSender := calldataload(0xa8)
        }
        if (origSender == address(vault)) {
            forta.raiseAlert(user);
        }
    }
}

contract DoubleEntryPointTest is Test {
    address me = makeAddr("me");
    CryptoVault vault;
    LegacyToken legacyToken;
    DoubleEntryPoint dbtToken;
    Forta forta;

    function setUp() external {
        vault = new CryptoVault(address(this));
        legacyToken = new LegacyToken();
        forta = new Forta();
        dbtToken = new DoubleEntryPoint(address(legacyToken), address(vault), address(forta), me);
        vault.setUnderlying(address(dbtToken));
        legacyToken.mint(address(vault), 100 ether);
        legacyToken.delegateToNewContract(dbtToken);
    }

    function testDoubleEntryPointHack() external {
        // attack
        vm.startPrank(me);

        DetectionBot bot = new DetectionBot(address(vault), address(dbtToken), address(forta));
        forta.setDetectionBot(address(bot));

        // to drain the dbtToken from the vault, we need to use the delegateTransfer method of dbtToken contract
        // however, the caller must be the legacy token contract
        // so we can call the sweepToken function of the vault contract with params is the LegacyToken address

        vm.expectRevert();
        vault.sweepToken(legacyToken);
    }
}
