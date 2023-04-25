import { ethers } from "hardhat";
import { REGISTRAR_ADDRESS } from "../constants";
import { verify } from "../utils/verify";

async function main() {
    // const accounts = await ethers.getSigners();
    // const deployer = accounts[0];

    // const Registrar = await ethers.getContractFactory("Registrar");
    // const registrar = await Registrar.deploy();

    // await registrar.deployed();

    if (process.env.ETHERSCAN_API_KEY) {
        console.log("Verifying Contract...");
        await verify(REGISTRAR_ADDRESS, []);
        console.log("Verified!");
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
