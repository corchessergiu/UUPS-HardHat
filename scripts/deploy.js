require("@openzeppelin/hardhat-upgrades");
require("@nomicfoundation/hardhat-toolbox");
const { ethers, upgrades } = require("hardhat");

async function main() {
  // Get the list of accounts provided by Hardhat
  const accounts = await ethers.getSigners();
  // Select the first account for deployment
  const deployer = accounts[0];
  console.log("Deploying ERC20Swapper with the account:", deployer.address);

  const ERC20Swapper = await ethers.getContractFactory(
    "ERC20Swapper",
    deployer
  );
  console.log("Deploying ERC20Swapper...");

  const swapRouterAddress = accounts[1].address; // Replace with actual Uniswap V3 Router address on Sepolia
  const wethAddress = accounts[2].address; // Replace with actual WETH address on Sepolia
  console.log("Swapper: ");
  console.log(swapRouterAddress);

  const proxyV1 = await upgrades.deployProxy(
    ERC20Swapper,
    [swapRouterAddress, wethAddress],
    { 
      initializer: "initialize",
      kind:"uups"
     }
  );
  await proxyV1.waitForDeployment();
  let proxyAddress = await proxyV1.getAddress();
  console.log("Proxy contract address: ");
  console.log(proxyAddress);

  await proxyV1.increase();
  console.log(Number(await proxyV1.numberOfInteraction()));
  await proxyV1.increase();
  console.log(Number(await proxyV1.numberOfInteraction()));

  const ERC20SwapperV2 = await ethers.getContractFactory("ERC20SwapperV2");
  const proxyV2 = await upgrades.upgradeProxy(proxyAddress, ERC20SwapperV2);
  await proxyV2.waitForDeployment();
  
  console.log("Proxy V2 address: ", await proxyV2.getAddress());
  console.log(
    "Current numner of interaction: ",
    Number(await proxyV2.numberOfInteraction())
  );
  await proxyV2.increaseBy2();
   console.log(
     "Current numner of interaction using increase from proxyv2: ",
     Number(await proxyV2.numberOfInteraction())
   );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
