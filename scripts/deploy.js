const hre = require("hardhat");
// Upload deployed to address 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
// UploadV2 deployed to address 0xF7Ab2aB18423853c924106B8d5D9Ca64B87b93B0
async function main() {

  const Upload = await hre.ethers.getContractFactory("Upload");
  const upload = await Upload.deploy();

  await upload.waitForDeployment();

  console.log(
    `Upload deployed to address ${upload.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
