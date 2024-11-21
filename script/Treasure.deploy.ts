import { upgrades, run, ethers } from "hardhat";
import hre from "hardhat";
import fs from "fs";
import { StakingNFT__factory, Treasure__factory } from "../typechain-types";

async function main() {
  const accounts = await ethers.getSigners();
  const sender = accounts[0].address;
  const balance = await ethers.provider.getBalance(sender);

  const network = hre.network.name;

  console.log(`Network: ${network}`);
  console.log("Sender address: ", sender);
  console.log("Sender Balance: ", Number(balance) / 1e18);

  const collection = "0x20b7287a72c68602a6b9e3b7f0d8ac0e1b02d2b4";
  const stakingAddress = "0x2271F2F502eFE6852A9375bEbc7a8873C1B062Aa";
  const token = "0xdac17f958d2ee523a2206206994597c13d831ec7";

  const contract = await new Treasure__factory(accounts[0]).deploy(
    sender,
    collection,
    stakingAddress,
    token,
  );

  await contract.deploymentTransaction()?.wait(5);

  console.log("Treasure deployed to:", await contract.getAddress());

  if (network != "hardhat") {
    console.log("start verification...");
    await run(`verify:verify`, {
      address: await contract.getAddress(),
      constructorArguments: [sender, collection, stakingAddress, token],
    });
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
