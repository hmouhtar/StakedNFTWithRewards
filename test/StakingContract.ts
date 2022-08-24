import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import chai from "chai";
import { ethers, waffle } from "hardhat";
import RewardToken from "../artifacts/contracts/RewardToken.sol/RewardToken.json";
import SampleNFT from "../artifacts/contracts/SampleNFT.sol/SampleNFT.json";

describe("StakingContract", function () {
  const stakeParams = {
    tokenId: 1,
    deadline: new Date().getTime(),
    signature: ethers.utils.randomBytes(8),
  };

  async function deployFixture() {
    const [mainAccount, secondaryAccount] = await ethers.getSigners();
    const mockRewardToken = await waffle.deployMockContract(
      mainAccount,
      RewardToken.abi
    );
    const mockSampleNFT = await waffle.deployMockContract(
      mainAccount,
      SampleNFT.abi
    );
    const StakingContract = await ethers.getContractFactory("StakingContract");
    const stakingContract = await StakingContract.deploy(
      mockRewardToken.address,
      mockSampleNFT.address
    );
    return {
      mainAccount,
      secondaryAccount,
      stakingContract,
      mockRewardToken,
      mockSampleNFT,
    };
  }

  async function stake(
    stakeParams: any,
    nftContract: any,
    stakingContract: any
  ) {
    await nftContract.mock.safeTransferFromWithPermit.returns();

    await stakingContract["stake(uint256,uint256,bytes)"](
      stakeParams.tokenId,
      stakeParams.deadline,
      stakeParams.signature
    );
  }

  describe("Staking and Unstaking", function () {
    it("Should transfer NFT to contract when staking", async function () {
      const {
        mainAccount,
        secondaryAccount,
        stakingContract,
        mockRewardToken,
        mockSampleNFT,
      } = await loadFixture(deployFixture);

      await stake(stakeParams, mockSampleNFT, stakingContract);

      // Hardhat-waffle doesn't support calledOnContractWith.
      /* chai
        .expect("safeTransferFromWithPermit")
        .to.be.calledOnContractWith(mockSampleNFT, [
          mainAccount,
          stakingContract.address,
          stakeParams.tokenId,
          stakeParams.deadline,
          stakeParams.signature,
        ]); */

      chai
        .expect(
          (await stakingContract.stakers(mainAccount.address)).amountStaked
        )
        .to.equal(1);
      chai
        .expect(await stakingContract.tokenToOwner(stakeParams.tokenId))
        .to.equal(mainAccount.address);
    });
    it("Should transfer NFT to owner when unstaking", async function () {
      const {
        mainAccount,
        secondaryAccount,
        stakingContract,
        mockRewardToken,
        mockSampleNFT,
      } = await loadFixture(deployFixture);

      await mockSampleNFT.mock.transferFrom.returns();

      await stake(stakeParams, mockSampleNFT, stakingContract);

      await stakingContract.unstake(1);

      chai
        .expect(
          (await stakingContract.stakers(mainAccount.address)).amountStaked
        )
        .to.equal(0);
      chai
        .expect(await stakingContract.tokenToOwner(stakeParams.tokenId))
        .to.equal("0x0000000000000000000000000000000000000000");
    });
  });
  describe("Rewards", function () {
    it("Should generate 10 tokens per staked NFT every 24hrs", async function () {});
    it("Should update rewards on staking and unstaking", async function () {});
    it("Should allow withdrawal of rewards", async function () {});
  });
});
