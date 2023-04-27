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
        const potentialOwners = [otherAccount[0].address, otherAccount[0].address, otherAccount[2].address];
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

    describe("Minting", function () {
        it("Should mint", async function () {
            const { society, potentialOwners, plotAddresses } = await loadFixture(DeploySociety);
            await society.mintNFT(potentialOwners[0], plotAddresses[0]);
        });
        it("Token Id starts from 1", async function () {
            const { society, potentialOwners, plotAddresses } = await loadFixture(DeploySociety);
            await society.mintNFT(potentialOwners[0], plotAddresses[0]);
            const tokenId = await society.getTokenIdOfPlot(plotAddresses[0]);
            expect(tokenId == ethers.BigNumber.from(1), "error in getting tokenId of plot");
        });
        it("Un minted plots have token id '0'", async function () {
            const { society, potentialOwners, plotAddresses } = await loadFixture(DeploySociety);
            await society.mintNFT(potentialOwners[0], plotAddresses[0]);
            const tokenId = await society.getTokenIdOfPlot(plotAddresses[2]);
            expect(tokenId == ethers.BigNumber.from(0), "error in getting tokenId of plot");
        });
    });

    describe("Get Plots", function () {
        it("Get all potential plots", async function () {
            const { society, potentialOwners } = await loadFixture(DeploySociety);
            const potentialPlots = await society.getAllPotentialPlots(potentialOwners[0]);
        });
        it("Get all owned plots", async function () {
            const { society, potentialOwners, plotAddresses } = await loadFixture(DeploySociety);
            await society.mintNFT(potentialOwners[0], plotAddresses[0]);
            const ownedPlots = await society.getAllOwnedPlots(potentialOwners[0]);
        });
        it("Get both potential and owned plots", async function () {
            const { society, potentialOwners, plotAddresses } = await loadFixture(DeploySociety);
            await society.mintNFT(potentialOwners[0], plotAddresses[0]);
            const potentialPlots = await society.getAllPotentialPlots(potentialOwners[0]);
            const ownedPlots = await society.getAllOwnedPlots(potentialOwners[0]);
        });
    });
});
