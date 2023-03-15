// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

//import "forge-std/Script.sol";
import "../lib/forge-std/src/Script.sol";
import "../test/TestUtils.sol";
import "../test/ERC20Mintable.sol";
import "../src/LukiswapV3Manager.sol";
import "../src/LukiswapV3pool.sol";
import "../lib/forge-std/src/console.sol";
import "../src/LukiswapV3Quoter.sol";
import "../src/LukiswapV3Factory.sol";
//import "../src/lib/Math.sol";
import "../src/lib/FixedPoint96.sol";
import "../src/interfaces/ILukiswapV3Manager.sol";



contract Deploy is Script, TestUtils {
    struct TokenBalances {
        uint256 uni;
        uint256 usdc;
        uint256 usdt;
        uint256 wbtc;
        uint256 weth;
    }

    TokenBalances balances =
        TokenBalances({
            uni: 200 ether,
            usdc: 2_000_000 ether,
            usdt: 2_000_000 ether,
            wbtc: 20 ether,
            weth: 100 ether
        });

    function run() public {
        // DEPLOYING STARGED
        vm.startBroadcast();

        ERC20Mintable weth = new ERC20Mintable("Wrapped Ether", "WETH", 18);
        ERC20Mintable usdc = new ERC20Mintable("USD Coin", "USDC", 18);
        ERC20Mintable uni = new ERC20Mintable("Uniswap Coin", "UNI", 18);
        ERC20Mintable wbtc = new ERC20Mintable("Wrapped Bitcoin", "WBTC", 18);
        ERC20Mintable usdt = new ERC20Mintable("USD Token", "USDT", 18);

        LukiswapV3Factory factory = new LukiswapV3Factory();
        LukiswapV3Manager manager = new LukiswapV3Manager(address(factory));
        LukiswapV3Quoter quoter = new LukiswapV3Quoter(address(factory));

        LukiswapV3pool wethUsdc = deployPool(
            factory,
            address(weth),
            address(usdc),
            60,
            5000
        );

        LukiswapV3pool wethUni = deployPool(
            factory,
            address(weth),
            address(uni),
            60,
            10
        );

        LukiswapV3pool wbtcUSDT = deployPool(
            factory,
            address(wbtc),
            address(usdt),
            60,
            20_000
        );

        LukiswapV3pool usdtUSDC = deployPool(
            factory,
            address(usdt),
            address(usdc),
            10,
            1
        );

        uni.mint(msg.sender, balances.uni);
        usdc.mint(msg.sender, balances.usdc);
        usdt.mint(msg.sender, balances.usdt);
        wbtc.mint(msg.sender, balances.wbtc);
        weth.mint(msg.sender, balances.weth);

        uni.approve(address(manager), 100 ether);
        usdc.approve(address(manager), 1_005_000 ether);
        usdt.approve(address(manager), 1_200_000 ether);
        wbtc.approve(address(manager), 10 ether);
        weth.approve(address(manager), 11 ether);

        manager.mint(
            mintParams(
                address(weth),
                address(usdc),
                4545,
                5500,
                1 ether,
                5000 ether
            )
        );
        manager.mint(
            mintParams(address(weth), address(uni), 7, 13, 10 ether, 100 ether)
        );

        manager.mint(
            mintParams(
                address(wbtc),
                address(usdt),
                19400,
                20500,
                10 ether,
                200_000 ether
            )
        );
        manager.mint(
            mintParams(
                address(usdt),
                address(usdc),
                uint160(77222060634363714391462903808), //  0.95, int(math.sqrt(0.95) * 2**96)
                uint160(81286379615119694729911992320), // ~1.05, int(math.sqrt(1/0.95) * 2**96)
                1_000_000 ether,
                1_000_000 ether,
                10
            )
        );

        vm.stopBroadcast();
        // DEPLOYING DONE

        console.log("WETH address", address(weth));
        console.log("UNI address", address(uni));
        console.log("USDC address", address(usdc));
        console.log("USDT address", address(usdt));
        console.log("WBTC address", address(wbtc));

        console.log("Factory address", address(factory));
        console.log("Manager address", address(manager));
        console.log("Quoter address", address(quoter));

        console.log("USDT/USDC address", address(usdtUSDC));
        console.log("WBTC/USDT address", address(wbtcUSDT));
        console.log("WETH/UNI address", address(wethUni));
        console.log("WETH/USDC address", address(wethUsdc));
    }
}