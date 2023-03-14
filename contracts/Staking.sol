// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./IERC20.sol";

contract Staking is ReentrancyGuard, Ownable {
    IERC20 rewardToken;

    uint256 private _rewardTokenBalance;
    address public nftContractAddress;
    address public stakingVault;
    uint256 public timeUnit;
    uint256 public rewardsPerUnitTime;

    struct StakingInfo {
        address staker;
        uint256 tokenId;
        uint256 stakedTime;
    }

    mapping( address => StakingInfo[] ) public stakedNftsPerWallet;
    mapping( address => uint256 ) public lastClaimedTime;

    constructor( 
        address rewardTokenAddress_, 
        address nftContractAddress_, 
        address stakingVault_ 
    ) {
        rewardToken = IERC20( rewardTokenAddress_ );
        nftContractAddress = nftContractAddress_;
        stakingVault = stakingVault_;
    }

    function depositRewardToken( uint256 amount_ ) external virtual nonReentrant onlyOwner {
        _depositRewardToken( amount_ );
    }

    function withdrawRewardToken( uint256 amount_ ) external virtual nonReentrant onlyOwner {
        _withdrawRewardToken( amount_ );
    }

    function stakeNft( uint256 tokenId_ ) external returns ( uint256 ) {
        IERC721 nftContract = IERC721( nftContractAddress);

        address owner = _msgSender();
        require( nftContract.ownerOf( tokenId_ ) == owner, "The NFT isn't owned by you" );
        nftContract.transferFrom( owner, address( this ), tokenId_ );
        StakingInfo memory _stakingInfo = StakingInfo(
            owner, 
            tokenId_, 
            block.timestamp 
        );

        StakingInfo[] storage _stakingInfos = stakedNftsPerWallet[ owner ];
        _stakingInfos.push( _stakingInfo );
        stakedNftsPerWallet[ owner ] = _stakingInfos;

        emit NftStaked( owner, tokenId_, block.timestamp);

        return tokenId_;
    }

    function claimReward() public returns ( uint256 ) {
        address owner = _msgSender();
        StakingInfo[] storage _stakingInfos = stakedNftsPerWallet[ owner ];
        uint256 length = _stakingInfos.length;
        uint256 totalReward;

        for ( uint256 i = 0; i < length; i++ ) {
            if ( lastClaimedTime[ owner ] < _stakingInfos[i].stakedTime ) {
                lastClaimedTime[ owner ] = _stakingInfos[i].stakedTime;
            }

            uint256 reward = ( ( block.timestamp - lastClaimedTime[ owner ] ) / timeUnit ) * rewardsPerUnitTime;
            totalReward += reward;
        }

        rewardToken.transferFrom(
            address( this) ,
            owner,
            ( totalReward * 8 ) / 10
        );
        rewardToken.transferFrom(
            address( this ),
            stakingVault,
            ( totalReward * 1 ) / 10
        );
        rewardToken.burn( ( totalReward * 1 ) / 10 );

        emit RewardClaimed( owner, totalReward );

        return totalReward;
    }

    function unstakeNft( uint256 tokenId_ ) external returns ( uint256 ) {
        IERC721 nftContract = IERC721( nftContractAddress );

        address owner = _msgSender();
        require( nftContract.ownerOf( tokenId_ ) == address( this ), "The NFT doesn't exist in this contract" );
        StakingInfo[] storage _stakingInfos = stakedNftsPerWallet[ owner ];
        uint256 length = _stakingInfos.length;
        bool flag;

        for ( uint256 i = 0; i < length; i++ ) {
            if (
                _stakingInfos[i].staker == owner && 
                _stakingInfos[i].tokenId == tokenId_ 
            ) {
                flag = true;
                _stakingInfos[i] = _stakingInfos[length - 1];
                _stakingInfos.pop();
                break;
            }
        }

        require( flag == true, "The NFT is not staked by you" );
        nftContract.transferFrom( address( this ), owner, tokenId_ );
        stakedNftsPerWallet[ owner ] = _stakingInfos;

        emit NftUnstaked( owner, tokenId_, block.timestamp );

        return tokenId_;
    }

    function getRewardTokenBalance() external view returns ( uint256 ) {
        return _rewardTokenBalance;
    }

    function setRewardsPerUnitTime( 
        uint256 _timeUnit, 
        uint256 _rewardsPerUnitTime 
    ) external onlyOwner {
        timeUnit = _timeUnit;
        rewardsPerUnitTime = _rewardsPerUnitTime;
    }

    function setNftContractAddress( address _nftContractAddress ) external onlyOwner {
        nftContractAddress = _nftContractAddress;
    }

    function _depositRewardToken( uint256 amount_ ) internal virtual {
        address owner = _msgSender();
        uint256 balanceBefore = rewardToken.balanceOf(address( this ) );
        rewardToken.transferFrom( owner, address( this ), amount_ );
        uint256 actualAmount = rewardToken.balanceOf( address( this ) ) - balanceBefore;
        _rewardTokenBalance += actualAmount;
    }

    function _withdrawRewardToken( uint256 amount_ ) internal virtual {
        address owner = _msgSender();
        require( _rewardTokenBalance > amount_, "not enough balance" );
        rewardToken.transferFrom( address( this ), owner, amount_ );
        _rewardTokenBalance -= amount_;
    }

    event NftStaked( address indexed staker, uint256 tokenId, uint256 timestamp );
    event NftUnstaked( address indexed staker, uint256 tokenId, uint256 timestamp );
    event RewardClaimed( address indexed staker, uint256 rewardAmount );
}
