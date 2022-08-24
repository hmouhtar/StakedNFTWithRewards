# StakedNFTWithRewards

This project is composed of 3 contracts:

RewardToken: Basic ERC20 token that will be used to reward stakers of SampleNFT.
SampleNFT: ERC721 capped token implementing [EIP-4494](https://eips.ethereum.org/EIPS/eip-4494) to allow approval and staking with a single transaction.
StakingContract: A ERC721Receiver contract that handles staking. Users can stake SampleNFT tokens to generate RewardTokens. 

To execute the sample setup, run:

npx hardhat run scripts/deployAndTest.js

To execute the tests, run:

npx hardhat test