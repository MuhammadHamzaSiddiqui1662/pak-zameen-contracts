import { ethers } from "hardhat";
import { verify } from "../utils/verify";

async function main() {
    const accounts = await ethers.getSigners();
    const deployer = accounts[0];
    const args: any = [];

    const Registrar = await ethers.getContractFactory("Registrar");
    const registrar = await Registrar.deploy(...args);

    await registrar.deployed();

    console.log(`Registrar Contract Deployed at address: ${registrar.address} by signer: ${deployer.address}`);

    if (process.env.ETHERSCAN_API_KEY) {
        await verify(registrar.address, args);
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

