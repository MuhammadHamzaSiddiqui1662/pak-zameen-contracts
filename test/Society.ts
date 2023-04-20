// @ts-ignore
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";

describe("Society", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function DeploySociety() {
        // Contracts are deployed using the first signer/account by default
        const [owner, ...otherAccount] = await ethers.getSigners();

        // Constants required
        const societyName = "Gulberg";
        const societySymbol = "GLB";
        const potentialOwners = [otherAccount[0].address, otherAccount[1].address, otherAccount[2].address];
        const plotAddresses = [
            ethers.utils.formatBytes32String("A-463 Block-12 Gulberg"),
            ethers.utils.formatBytes32String("A-101 Block-12 Gulberg"),
            ethers.utils.formatBytes32String("B-506 Block-12 Gulberg"),
        ];

        const Society = await ethers.getContractFactory("Society");
        const society = await Society.deploy(societyName, societySymbol, plotAddresses, potentialOwners);

        return { society, societyName, societySymbol, potentialOwners, plotAddresses, owner, otherAccount };
    }

    describe("Deployment", function () {
        it("Should deploy", async function () {
            await loadFixture(DeploySociety);
        });
    });
});
