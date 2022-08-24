// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./RewardToken.sol";
import "./SampleNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract StakingContract is IERC721Receiver {
    RewardToken public immutable rewardToken;
    SampleNFT public immutable sampleNFT;
    uint256 public constant REWARDS_PER_HOUR = 0.41e18;

    struct Staker {
        uint256 amountStaked;
        uint256 timeOfLastUpdate;
        uint256 unclaimedRewards;
    }

    mapping(uint256 => address) public tokenToOwner;
    mapping(address => Staker) public stakers;

    constructor(address rewardTokenContract, address sampleNFTContract) {
        rewardToken = RewardToken(rewardTokenContract);
        sampleNFT = SampleNFT(sampleNFTContract);
    }

    modifier updateRewards() {
        uint256 rewards = calculateRewards(msg.sender);
        unchecked {
            stakers[msg.sender].unclaimedRewards += rewards;
        }
        stakers[msg.sender].timeOfLastUpdate = block.timestamp;
        _;
    }

    function stake(uint256 tokenId) external updateRewards {
        sampleNFT.safeTransferFrom(msg.sender, address(this), tokenId);
        stakers[msg.sender].amountStaked++;
    }

    function stake(
        uint256 tokenId,
        uint256 deadline,
        bytes memory signature
    ) external updateRewards {
        sampleNFT.safeTransferFromWithPermit(
            msg.sender,
            address(this),
            tokenId,
            deadline,
            signature
        );
        stakers[msg.sender].amountStaked++;
        tokenToOwner[tokenId] = msg.sender;
    }

    function unstake(uint256 tokenId) external updateRewards {
        require(msg.sender == tokenToOwner[tokenId]);
        stakers[msg.sender].amountStaked--;
        tokenToOwner[tokenId] = address(0);
        sampleNFT.transferFrom(address(this), msg.sender, tokenId);
    }

    function withdrawRewards() external updateRewards {
        uint256 unclaimedRewards = stakers[msg.sender].unclaimedRewards;
        require(unclaimedRewards > 0);
        rewardToken.mint(msg.sender, unclaimedRewards);
        stakers[msg.sender].unclaimedRewards = 0;
    }

    function calculateRewards(address account) public view returns (uint256) {
        Staker memory staker = stakers[account];
        return (((
            ((block.timestamp - staker.timeOfLastUpdate) * staker.amountStaked)
        ) * REWARDS_PER_HOUR) / 3600);
    }

    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
