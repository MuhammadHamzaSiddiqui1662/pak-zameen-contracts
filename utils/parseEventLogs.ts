import { ethers } from "hardhat";
import etherjs from "ethers";

export const parseEventLogs = async (hash: string, abi: any) => {
    const reciept = await ethers.provider.getTransactionReceipt(hash);
    const iEvents = new ethers.utils.Interface(abi);
    let eventInfo: etherjs.utils.LogDescription[] = [];

    for (let i = 0; i < reciept.logs.length; i++) {
        const log = reciept.logs[i];
        try {
            const eventData = iEvents.parseLog({ data: log.data, topics: log.topics });
            eventInfo.push(eventData!);
        } catch (error) {
            continue;
        }
    }
    return eventInfo;
};
