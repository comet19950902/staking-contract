// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";
import "./SafeMath.sol";

contract ERC20Token is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    string private _name = "RewardToken";
    string private _symbol = "RT";
    uint8 private _decimals = 18;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor( uint256 initialSupply_ ){
        _name = "RewardToken";
        _symbol = "RT";
        _decimals = 18;

        init( initialSupply_ );
    }

    function init( uint256 initialSupply_ ) private {
        address owner = _msgSender();
        _totalSupply = initialSupply_ * 10 ** uint256( decimals() );
        _balances[ owner ] = _totalSupply;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns( uint256 ){
        return _totalSupply;
    }

    function balanceOf( address account_ ) public view virtual override returns( uint256 ){
        return _balances[ account_ ];
    }

    function transfer( address to_, uint256 amount_ ) public virtual override returns( bool ){
        address owner = _msgSender();
        _transfer( owner, to_, amount_ );
        
        return true;
    }
    
    function allowance( address owner_, address spender_ ) public view virtual override returns( uint256 ){
        return _allowances[ owner_ ][ spender_ ];
    }
    
    function approve( address spender_, uint256 amount_ ) public virtual override returns( bool ){
        address owner = _msgSender();
        _approve( owner, spender_, amount_ );
        
        return true;
    }

    function transferFrom( address from_, address to_, uint256 amount_ ) public virtual override returns( bool ){
        address spender = _msgSender();
        _spendAllowance( from_, spender, amount_ );
        _transfer( from_, to_, amount_ );
        
        return true;
    }
    
    function burn( uint256 amount_ ) public virtual override returns (bool){
        address account = _msgSender();
        _burn( account, amount_ );
        
        return true;
    }

    function increaseAllowance( address spender, uint256 amount_ ) public returns( bool ){
        address owner = _msgSender();
        _approve( owner, spender, amount_ );
        
        return true;
    }

    function decreaseAllowance( address spender_, uint256 amount_ ) public returns( bool ){
        address owner = _msgSender();
        uint256 currentAllowance = allowance( owner, spender_ );
        require( currentAllowance >= amount_, "ERC20: decreased allowance below zero" );
        unchecked {
            _approve( owner, spender_, currentAllowance - amount_ );
        }

        return true;
    }
    
    function _mint( address account_, uint256 amount_ ) internal virtual {
        require( account_ != address(0), "ERC20: mint to the zero address" );

        _beforeTokenTransfer( address(0), account_, amount_);

        _totalSupply += amount_;
        unchecked {
            _balances[ account_ ] += amount_;
        }

        emit Transfer( address(0), account_, amount_);

        _afterTokenTransfer( address(0), account_, amount_);
    }

    function _transfer( address from_, address to_, uint256 amount_ ) internal virtual {
        require( from_ != address(0), "ERC20: transfer from the zero address");
        require( to_ != address(0), "ERC20: transfer to the zero address" );
        
        _beforeTokenTransfer(from_, to_, amount_);
        
        uint256 fromBalance = _balances[ from_ ];
        require( fromBalance >= amount_, "ERC20: transfer amount exceeds balance" );
        unchecked {
            _balances[ from_ ] = fromBalance - amount_;
            _balances[ to_ ] += amount_;
        }
        
        emit Transfer( from_, to_, amount_ );

        _afterTokenTransfer( from_, to_, amount_ );
    }

    function _spendAllowance( address owner_, address spender_, uint256 amount_ ) internal virtual {
        uint256 currentAllowance = allowance( owner_, spender_);
        if( currentAllowance != type( uint256 ).max ){
            require( currentAllowance >= amount_, "ERC20: insufficient allowance" );
            unchecked{
                _approve( owner_, spender_, currentAllowance - amount_ );
            }
        }
    }

    function _approve( address owner_, address spender_, uint256 amount_ ) internal virtual {
        require( owner_ != address(0), "ERC20: approve owner the zero address" );
        require( spender_ != address(0), "ERC20: approve spender the zero address" );

        _allowances[ owner_ ][ spender_ ] = amount_;
        emit Approval( owner_, spender_, amount_ );
    }

    function _burn( address account_, uint256 amount_ ) internal virtual {
        require( account_ != address(0), "ERC20: burn from the zero address" );

        _beforeTokenTransfer( account_, address(0), amount_);

        uint256 accountBalance = _balances[ account_ ];
        require( accountBalance >= amount_, "ERC20: burn amount exceedes balance" );
        unchecked{
            _balances[ account_ ] = accountBalance - amount_;
            _totalSupply -= amount_;
        }
        emit Transfer( account_, address(0), amount_ );

        _afterTokenTransfer( account_, address(0), amount_);
    }
    
    function _beforeTokenTransfer( 
        address from, address to, uint256 amount
    ) internal virtual {
        // do Something
    }
    
    function _afterTokenTransfer(
        address from, address to, uint256 amount
    ) internal virtual {
        // do Something    
    }
}
