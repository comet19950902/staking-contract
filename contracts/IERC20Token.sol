// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./ERC20Token.sol";

interface IERC20Token {
    function approve(address _spender, uint256 _amount) external returns (bool);

    function allowance(
        address _owner,
        address _spender
    ) external returns (uint256);

    function transfer(address _to, uint256 _amount) external;

    function transferFrom(address _from, address _to, uint256 _amount) external;

    function balanceOf(address _account) external returns (uint256);

    function burn(uint256 _amount) external returns (bool);
}
