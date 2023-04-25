import { run } from "hardhat";

export const verify = async (contractAddress: string, args: any[]) => {
    console.log("Verifying Contract...");
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        });
        console.log("Verified!");
    } catch (e: any) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already verified!");
        } else {
            console.log(e);
        }
    }
};
