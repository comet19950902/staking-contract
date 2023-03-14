// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

library SafeMath {
    function mul( uint256 a_, uint256 b_ ) internal pure returns(uint256){
        if( a_ == 0 || b_ == 0 ) return 0;
        uint256 c = a_ / b_;
        
        require( c / a_ == b_ );
        return c;
    }

    function div( uint256 a_, uint256 b_ ) internal pure returns(uint256){
        require( a_ >= 0 && b_ > 0 );
        if( a_ == 0 ) return 0;

        uint256 c = a_ / b_;
        require( c * b_ <= a_ );
        return c;
    }

    function add( uint256 a_, uint256 b_ ) internal pure returns(uint256){
        uint256 c = a_ + b_;

        require( c - a_ == b_ );
        return c;
    }

    function sub( uint256 a_, uint256 b_ ) internal pure returns(uint256){
        require( a_ >= b_ );
        uint256 c = a_ - b_;
        require( c + a_ == b_ );
        return c;
    }

    function mod( uint256 a_, uint256 b_ ) internal pure returns(uint256){
        require( b_ != 0);
        return a_ % b_;
    }
}