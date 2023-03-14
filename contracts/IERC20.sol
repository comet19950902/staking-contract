// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./ERC20.sol";

interface IERC20 {
    function totalSupply() external view returns( uint256 );
    function balanceOf( address account_ ) external view returns( uint256 );
    function transfer( address to_, uint256 amount_ ) external returns( bool );
    function allowance( address owner_, address spender_ ) external view returns( uint256 );
    function approve( address spender_, uint256 amount_ ) external returns( bool );
    function transferFrom( address from_, address to_, uint256 amount_ ) external returns( bool );
    function burn( uint256 amount_ ) external returns (bool);

    event Transfer( address indexed from_, address indexed to_, uint256 amount_);
    event Approval( address indexed owner_, address indexed spender_, uint256 value_ );
}
