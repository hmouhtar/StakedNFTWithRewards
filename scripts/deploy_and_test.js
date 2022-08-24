const hre = require("hardhat");

async function generateEIP2612Signature({ signer, spender, tokenId, verifyingContract, domainInfo, nonce }) {
    const digestParams = {
        spender: spender.address,
        tokenId,
        nonce: parseInt(await verifyingContract.nonces(tokenId)),
        deadline: new Date().getTime() + 60 * 60 * 24 * 1000,
    };

    const rawSignature = await signer._signTypedData(
        {
            name: domainInfo && domainInfo.name || "SampleNFT",
            version: domainInfo && domainInfo.version || "1",
            chainId: 31337,
            verifyingContract: verifyingContract.address
        },
        {
            Permit: [
                {
                    name: "spender",
                    type: "address",
                },
                {
                    name: "tokenId",
                    type: "uint256",
                },
                {
                    name: "nonce",
                    type: "uint256",
                },
                {
                    name: "deadline",
                    type: "uint256",
                },
            ],
        },
        digestParams
    );

    return [rawSignature, digestParams.deadline];
}

(async () => {
    const [mainAccount, secondaryAccount] = await hre.ethers.getSigners();

    const RewardToken = await hre.ethers.getContractFactory("RewardToken");
    const rewardToken = await RewardToken.deploy();
    await rewardToken.deployed();

    const SampleNFT = await hre.ethers.getContractFactory("SampleNFT");
    const sampleNFT = await SampleNFT.deploy("QmQsrxb2MSVZSJfC61ukoJm9dkPJD3z2aCzyHmq4Pz3Nm8");
    await sampleNFT.deployed();

    const StakingContract = await hre.ethers.getContractFactory("StakingContract");
    const stakingContract = await StakingContract.deploy(rewardToken.address, sampleNFT.address);
    await stakingContract.deployed();

    await rewardToken.transferOwnership(stakingContract.address);
    await sampleNFT.mint(mainAccount.address)

    let [signature, deadline] = await generateEIP2612Signature({
        signer: mainAccount,
        spender: stakingContract,
        tokenId: 1,
        verifyingContract: sampleNFT,
    });

    await stakingContract['stake(uint256,uint256,bytes)'](1, deadline, signature);

    // @TODO test rewards generation.

})()