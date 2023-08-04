
const ethers = require('ethers');

async function main() {

    //合约地址
    const addressContract = "0x7B42985F83851d7680D02a2589747806883A2d30";
    const addressTo = "0xba0bAc1569b1A44F014d040191B50a94305fc39c";
    //provider
    const providerUrl = "https://goerli.infura.io/v3/234ab35281e64c51abcac5c1b5809c57";
    const provider = new ethers.JsonRpcProvider(providerUrl);

    //ABI
    const abi = [
        "function name() view returns (string)",
        "function symbol() view returns (string)",
        "function balanceOf(address owner) view returns (uint256)",
        "function transfer(address to, uint amount) returns (bool)",
    ];

    //创建singer(请改用自己的key)
    const privateKey ="8b65a022ef484d6729a56e1005059b5a15843cb73937e20c6001778f6286033f";
    //连接provider
    const singer1 = new ethers.Wallet(privateKey,provider);
    //创建前端合约对象
    const contract = new ethers.Contract(addressContract, abi, singer1);
    console.log("name ->",await contract.name());
    console.log("symbol ->",await contract.symbol());
    //转账
    const tx = await contract.transfer(addressTo, ethers.parseEther("10"));
    tx.wait(1);
    console.log("to balance ->",ethers.formatEther(await contract.balanceOf(addressTo)));

}

main();

