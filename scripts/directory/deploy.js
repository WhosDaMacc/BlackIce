async function main() {
  // Get the contract factory and deploy the contract
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const GlacierNetwork = await ethers.getContractFactory("GlacierNetwork");
  const glacierNetwork = await GlacierNetwork.deploy();

  console.log("GlacierNetwork deployed to:", glacierNetwork.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });