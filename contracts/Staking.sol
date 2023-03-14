// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./IERC20Token.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is ReentrancyGuard, Ownable {
    IERC20Token rewardToken;

    uint256 private rewardTokenBalance;
    address public nftContractAddress;
    address public stakingVault;
    uint256 public timeUnit;
    uint256 public rewardsPerUnitTime;

    struct StakingInfo {
        address staker;
        uint256 tokenId;
        uint256 stakedTime;
    }

    mapping(address => StakingInfo[]) public stakedNftsPerWallet;
    mapping(address => uint256) public lastClaimedTime;

    constructor(
        address _rewardTokenAddress,
        address _nftContractAddress,
        address _stakingVault
    ) {
        rewardToken = IERC20Token(_rewardTokenAddress);
        nftContractAddress = _nftContractAddress;
        stakingVault = _stakingVault;
    }

    function depositRewardToken(
        uint256 _amount
    ) external virtual nonReentrant onlyOwner {
        _depositRewardToken(_amount);
    }

    function withdrawRewardToken(
        uint256 _amount
    ) external virtual nonReentrant onlyOwner {
        _withdrawRewardToken(_amount);
    }

    function stakeNft(uint256 _tokenId) external returns (uint256) {
        IERC721 nftContract = IERC721(nftContractAddress);

        require(
            nftContract.ownerOf(_tokenId) == msg.sender,
            "The NFT isn't owned by you"
        );

        nftContract.transferFrom(msg.sender, address(this), _tokenId);

        StakingInfo memory _stakingInfo = StakingInfo(
            msg.sender,
            _tokenId,
            block.timestamp
        );

        StakingInfo[] storage _stakingInfos = stakedNftsPerWallet[msg.sender];
        _stakingInfos.push(_stakingInfo);
        stakedNftsPerWallet[msg.sender] = _stakingInfos;

        emit NftStaked(msg.sender, _tokenId, block.timestamp);

        return _tokenId;
    }

    function claimReward() public returns (uint256) {
        StakingInfo[] storage _stakingInfos = stakedNftsPerWallet[msg.sender];
        uint256 length = _stakingInfos.length;
        uint256 totalReward;

        for (uint256 i = 0; i < length; i++) {
            if (lastClaimedTime[msg.sender] < _stakingInfos[i].stakedTime) {
                lastClaimedTime[msg.sender] = _stakingInfos[i].stakedTime;
            }

            uint256 reward = ((block.timestamp - lastClaimedTime[msg.sender]) /
                timeUnit) * rewardsPerUnitTime;
            totalReward += reward;
        }

        rewardToken.transferFrom(
            address(this),
            msg.sender,
            (totalReward * 8) / 10
        );
        rewardToken.transferFrom(
            address(this),
            stakingVault,
            (totalReward * 1) / 10
        );
        rewardToken.burn((totalReward * 1) / 10);

        emit RewardClaimed(msg.sender, totalReward);

        return totalReward;
    }

    function unstakeNft(uint256 _tokenId) external returns (uint256) {
        IERC721 nftContract = IERC721(nftContractAddress);

        require(
            nftContract.ownerOf(_tokenId) == address(this),
            "The NFT doesn't exist in this contract"
        );
        StakingInfo[] storage _stakingInfos = stakedNftsPerWallet[msg.sender];
        uint256 length = _stakingInfos.length;
        bool flag;

        for (uint256 i = 0; i < length; i++) {
            if (
                _stakingInfos[i].staker == msg.sender &&
                _stakingInfos[i].tokenId == _tokenId
            ) {
                flag = true;
                _stakingInfos[i] = _stakingInfos[length - 1];
                _stakingInfos.pop();
                break;
            }
        }

        require(flag == true, "The NFT is not staked by you");

        nftContract.transferFrom(address(this), msg.sender, _tokenId);

        stakedNftsPerWallet[msg.sender] = _stakingInfos;

        emit NftUnstaked(msg.sender, _tokenId, block.timestamp);

        return _tokenId;
    }

    function getRewardTokenBalance() external view returns (uint256) {
        return rewardTokenBalance;
    }

    function setRewardsPerUnitTime(
        uint256 _timeUnit,
        uint256 _rewardsPerUnitTime
    ) external onlyOwner {
        timeUnit = _timeUnit;
        rewardsPerUnitTime = _rewardsPerUnitTime;
    }

    function setNftContractAddress(
        address _nftContractAddress
    ) external onlyOwner {
        nftContractAddress = _nftContractAddress;
    }

    function _depositRewardToken(uint256 _amount) internal virtual {
        uint256 balanceBefore = rewardToken.balanceOf(address(this));

        rewardToken.transferFrom(msg.sender, address(this), _amount);

        uint256 actualAmount = rewardToken.balanceOf(address(this)) -
            balanceBefore;

        rewardTokenBalance += actualAmount;
    }

    function _withdrawRewardToken(uint256 _amount) internal virtual {
        require(rewardTokenBalance > _amount, "not enough balance");

        rewardToken.transferFrom(address(this), msg.sender, _amount);

        rewardTokenBalance -= _amount;
    }

    event NftStaked(address indexed staker, uint256 tokenId, uint256 timestamp);

    event NftUnstaked(
        address indexed staker,
        uint256 tokenId,
        uint256 timestamp
    );

    event RewardClaimed(address indexed staker, uint256 rewardAmount);
}
