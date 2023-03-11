// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "../src/interfaces/ILukiswapV3PoolDeployer.sol";
import "./LukiswapV3pool.sol";
import "../src/interfaces/IERC20.sol";
import "./LukiswapV3pool.sol";


contract LukiswapV3Factory is ILukiswapV3PoolDeployer {
    error PoolAlreadyExists();
    error ZeroAddressNotAllowed();
    error TokensMustBeDifferent();
    error UnsupportedTickSpacing();

    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed tickSpacing,
        address pool
    );

    PoolParameters public parameters;

    mapping(uint24 => bool) public tickSpacings;
    mapping(address => mapping(address => mapping(uint24 => address)))
        public pools;

    constructor() {
        tickSpacings[10] = true;
        tickSpacings[60] = true;
    }

    function createPool(
        address tokenX,
        address tokenY,
        uint24 tickSpacing
    ) public returns (address pool) {
        if (tokenX == tokenY) revert TokensMustBeDifferent();
        if (!tickSpacings[tickSpacing]) revert UnsupportedTickSpacing();

        (tokenX, tokenY) = tokenX < tokenY
            ? (tokenX, tokenY)
            : (tokenY, tokenX);

        if (tokenX == address(0)) revert ZeroAddressNotAllowed();
        if (pools[tokenX][tokenY][tickSpacing] != address(0))
            revert PoolAlreadyExists();

        parameters = PoolParameters({
            factory: address(this),
            token0: tokenX,
            token1: tokenY,
            tickSpacing: tickSpacing
        });

        pool = address(
            new LukiswapV3pool{
                salt: keccak256(abi.encodePacked(tokenX, tokenY, tickSpacing))
            }()
        );

        delete parameters;

        pools[tokenX][tokenY][tickSpacing] = pool;
        pools[tokenY][tokenX][tickSpacing] = pool;

        emit PoolCreated(tokenX, tokenY, tickSpacing, pool);
    }
}