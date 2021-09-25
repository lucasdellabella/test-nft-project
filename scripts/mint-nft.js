require('dotenv').config();
const { createAlchemyWeb3 } = require("@alch/alchemy-web3");
const web3 = createAlchemyWeb3(process.env.API_URL);
const contract = require("../artifacts/contracts/MyNFT.sol/MyNFT.json");
console.log(JSON.stringify(contract.abi));

