import { ethers } from "hardhat";

async function main() {
    // const accounts = await ethers.getSigners();
    // const deployer = accounts[0];

    // const Registrar = await ethers.getContractFactory("Registrar");
    // const registrar = await Registrar.deploy();

    // await registrar.deployed();

    console.log(`Scripts running...`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
