import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { parseEventLogs } from "../utils/parseEventLogs";
import { abi } from "../artifacts/contracts/Registrar.sol/Registrar.json";

describe("Registrar", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function DeployRegistrarFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, ...otherAccount] = await ethers.getSigners();

        // Constants required
        const societyName = "Gulberg";
        const societySymbol = "GLB";
        const potentialOwners = [
            owner.address,
            owner.address,
            otherAccount[0].address,
            otherAccount[1].address,
            otherAccount[2].address,
        ];
        const plotAddresses = [
            ethers.utils.formatBytes32String("A-930 Block-12 Gulberg"),
            ethers.utils.formatBytes32String("A-101 Block-12 Gulberg"),
            ethers.utils.formatBytes32String("B-506 Block-12 Gulberg"),
            ethers.utils.formatBytes32String("C-26 Block-12 Gulberg"),
            ethers.utils.formatBytes32String("ST-5 Block-12 Gulberg"),
        ];

        const Registrar = await ethers.getContractFactory("Registrar");
        const registrar = await Registrar.deploy();

        const societyRecipt = await (
            await registrar.createSociety(societyName, societySymbol, plotAddresses, potentialOwners)
        ).wait();

        const societyAddress = await registrar.societyToAddress(societyName);

        const Society = await ethers.getContractFactory("Society");
        const society = await Society.attach(societyAddress);

        return {
            registrar,
            societyName,
            societySymbol,
            potentialOwners,
            plotAddresses,
            owner,
            otherAccount,
            society,
            societyAddress,
            societyRecipt,
        };
    }

    async function InitiateSaleFixture() {
        const { registrar, plotAddresses, societyAddress, ...others } = await loadFixture(DeployRegistrarFixture);
        const tokenId = (await registrar.claimAsset(societyAddress, plotAddresses[0])).value;
        const saleId = (await registrar.initiateSale(societyAddress, plotAddresses[0], ethers.BigNumber.from(200)))
            .value;

        return {
            registrar,
            plotAddresses,
            societyAddress,
            tokenId,
            saleId,
            ...others,
        };
    }

    describe("Deployment", function () {
        it("Should create a valid scoiety", async function () {
            const { registrar, societyName, societyRecipt } = await loadFixture(DeployRegistrarFixture);
            const societyAddressByEvent = (await parseEventLogs(societyRecipt.transactionHash, abi))[0].args
                .societyAddress;
            const societyAddressByContractMapping = await registrar.societyToAddress(societyName);

            expect(societyAddressByContractMapping).to.equal(societyAddressByEvent);
        });

        it("Token Counter increasing", async function () {
            const { registrar, plotAddresses, societyAddress } = await loadFixture(DeployRegistrarFixture);
            const tokenId1 = (await registrar.claimAsset(societyAddress, plotAddresses[0])).value;
            const tokenId2 = (await registrar.claimAsset(societyAddress, plotAddresses[1])).value;
            expect(tokenId2.toString() == "2", "Counter is not working correctly");
        });
    });

    describe("Mint Assets", function () {
        it("only potential owner can mint", async function () {
            const { registrar, plotAddresses, potentialOwners, societyAddress, society } = await loadFixture(
                DeployRegistrarFixture
            );
            const tokenId = (await registrar.claimAsset(societyAddress, plotAddresses[0])).value;

            const owner = await society.ownerOf(tokenId);
            expect(owner == potentialOwners[0], "Only Potential Owner can mint");
        });

        it("other than potential owner can not mint", async function () {
            const { registrar, plotAddresses, societyAddress } = await loadFixture(DeployRegistrarFixture);
            await expect(registrar.claimAsset(societyAddress, plotAddresses[2])).to.be.revertedWith(
                "Not Potential Owner"
            );
        });
    });

    describe("Get Values", function () {
        it("get all sales", async function () {
            const { registrar } = await loadFixture(InitiateSaleFixture);
            const sales = await registrar.getAllSales();
            expect(sales.length > 0, "error in getting all sales");
        });
        it("get sales counter", async function () {
            const { registrar } = await loadFixture(InitiateSaleFixture);
            const saleCounter = await registrar.s_saleCounter();
            expect(saleCounter.toNumber() > 0, "error in getting all sales");
        });
    });
});
