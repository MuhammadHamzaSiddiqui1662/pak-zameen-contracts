import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { parseEventLogs } from "../utils/parseEventLogs";
import { abi } from "../artifacts/contracts/Registrar.sol/Registrar.json";

describe("Registrar", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function DeployRegistrar() {
        // Contracts are deployed using the first signer/account by default
        const [owner, ...otherAccount] = await ethers.getSigners();

        // Constants required
        const societyName = "Gulberg";
        const societySymbol = "GLB";
        const potentialOwners = [otherAccount[0].address, otherAccount[1].address, otherAccount[2].address];
        const plotAddresses = [
            ethers.utils.formatBytes32String("A-930 Block-12 Gulberg"),
            ethers.utils.formatBytes32String("A-101 Block-12 Gulberg"),
            ethers.utils.formatBytes32String("B-506 Block-12 Gulberg"),
        ];

        const Registrar = await ethers.getContractFactory("Registrar");
        const registrar = await Registrar.deploy();

        return { registrar, societyName, societySymbol, potentialOwners, plotAddresses, owner, otherAccount };
    }

    describe("Deployment", function () {
        it("Should create a valid scoiety", async function () {
            const { registrar, societyName, societySymbol, plotAddresses, potentialOwners } = await loadFixture(
                DeployRegistrar
            );
            console.log(societyName);
            const societyRecipt = await (
                await registrar.createSociety(societyName, societySymbol, plotAddresses, potentialOwners)
            ).wait();
            const societyAddressByEvent = (await parseEventLogs(societyRecipt.transactionHash, abi))[0].args
                .societyAddress;
            const societyAddressByContractMapping = await registrar.societyToAddress(societyName);

            expect(societyAddressByContractMapping).to.equal(societyAddressByEvent);
        });
    });
});
