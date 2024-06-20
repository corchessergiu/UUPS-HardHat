require("@openzeppelin/hardhat-upgrades");
require("@nomicfoundation/hardhat-toolbox");
const { ethers, upgrades } = require("hardhat");

async function main() {
  // Get the list of accounts provided by Hardhat
  const accounts = await ethers.getSigners();
  // Select the first account for deployment
  const deployer = accounts[0];
  console.log("Deploying ERC20Swapper with the account:", deployer.address);

  //Get ERC20Swapper contract instance
  const ERC20Swapper = await ethers.getContractFactory(
    "ERC20Swapper",
    deployer
  );
  console.log("Deploying ERC20Swapper...");

  //Select some dummy addresses for weth and swap router
  const swapRouterAddress = accounts[1].address; // Replace with actual Uniswap V3 Router address on Sepolia
  const wethAddress = accounts[2].address; // Replace with actual WETH address on Sepolia

  //Deploy proxy V1
  const proxyV1 = await upgrades.deployProxy(
    ERC20Swapper,
    [swapRouterAddress, wethAddress],
    {
      initializer: "initialize",
      kind: "uups",
    }
  );
  await proxyV1.waitForDeployment();

  let proxyAddress = await proxyV1.getAddress();
  console.log("Proxy contract address: ", proxyAddress);

  //These functions are used solely to demonstrate that UUPS works!
  await proxyV1.increase();
  console.log("ProxyV1 counter: ",Number(await proxyV1.numberOfInteraction()));
  await proxyV1.increase();
  console.log("ProxyV1 counter: ",Number(await proxyV1.numberOfInteraction()));

  //Get ERC20SwapperV2 contract instance
  const ERC20SwapperV2 = await ethers.getContractFactory("ERC20SwapperV2");
  const proxyV2 = await upgrades.upgradeProxy(proxyAddress, ERC20SwapperV2);
  await proxyV2.waitForDeployment();

  //The address for the proxy will be the same, only implementation address it will change
  console.log("Proxy V2 address: ", await proxyV2.getAddress());
  //Storage is persistent between implementation V1 and implementation V2
  console.log("Current numner of interaction, call made using ProxyV2: ", Number(await proxyV2.numberOfInteraction()));

  await proxyV2.increaseBy2();
  console.log("ProxyV2 after increase by 2: ",Number(await proxyV2.numberOfInteraction()));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
