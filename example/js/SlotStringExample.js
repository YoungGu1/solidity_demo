const ethers = require('ethers');

const providerUrl = "https://goerli.infura.io/v3/234ab35281e64c51abcac5c1b5809c57";
const provider = new ethers.providers.JsonRpcProvider(providerUrl);
const contractAddress = "0x7775f8EE61139A9745f1b32A1A93CFe44A200138";
const contractABI = [
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "slot",
                "type": "uint256"
            }
        ],
        "name": "getBytes32BySlot",
        "outputs": [
            {
                "internalType": "bytes32",
                "name": "",
                "type": "bytes32"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "slot",
                "type": "uint256"
            }
        ],
        "name": "getFirstSlot",
        "outputs": [
            {
                "internalType": "bytes32",
                "name": "",
                "type": "bytes32"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "slot",
                "type": "uint256"
            }
        ],
        "name": "getSecondSlot",
        "outputs": [
            {
                "internalType": "bytes32",
                "name": "",
                "type": "bytes32"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    }
];
const contract = new ethers.Contract(contractAddress, contractABI, provider);

async function getGreaterThan32String(contractAddress, slot) {
    //把插槽转换成32字节的16进制，如: 0x0000000000000000000000000000000000000000000000000000000000000000
    const slot0Hex = ethers.utils.hexZeroPad(slot, 32);
    console.log("slot0Hex ->",slot0Hex);
    //获取特定插槽位置的数据，如果是大于32字节的数据，插槽存放的是数据的长度(16进制表示)
    const slot0DataLength = await provider.getStorageAt(contractAddress, slot0Hex);
    console.log("slot0DataLength ->",slot0DataLength);
    //真正储存数据的起始插槽
    const baseSlotData = ethers.utils.keccak256(slot0Hex);
    console.log("baseSlotData ->",baseSlotData);
    //16进制右移一位，也就是÷2，然后转换成10进制(计算出来数据有多少位，后续要占用多少插槽)
    const dataByteLength = ethers.BigNumber.from(slot0DataLength).shr(1).toNumber();
    console.log("dataByteLength ->",dataByteLength);
    //计算字符串占用多少个插槽
    const totalSlots = Math.ceil(dataByteLength / 32);
    console.log("totalSlots ->",totalSlots);
    //将插槽转换成16进制
    let slotDataLocation = baseSlotData;
    console.log("slotDataLocation ->",slotDataLocation);
    let helloData = "";

    for (let i = 1; i <= totalSlots; i++) {
        //获取插槽里面的值
        const eachSlotData = await provider.getStorageAt(contractAddress, slotDataLocation);
        const eachSlotString = ethers.utils.toUtf8String(eachSlotData);
        console.log("eachSlotString ->",i,"->",eachSlotString);
        helloData = helloData.concat(eachSlotString);
        //获取连续插槽地址
        slotDataLocation = ethers.BigNumber.from(baseSlotData).add(i).toHexString();
    }

    console.log("helloData ->",helloData);
    //return str.replace(/\x00/g, '');
    return helloData;
}

const hello = getGreaterThan32String(contractAddress, 0x00);