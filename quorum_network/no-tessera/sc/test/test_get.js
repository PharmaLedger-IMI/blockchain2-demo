function getFactory(rpcAddress, contractAddress, abi, account) {
    this.web3 = buildFactory(rpcAddress, contractAddress, abi);
    this.contract = new this.web3.eth.Contract(abi, contractAddress);

    function buildFactory(rpcAddress) {
        const Web3 = require('web3');
        return new Web3(new Web3.providers.HttpProvider(rpcAddress));
    }

    return this.contract;

}

function getAbi(){
    const fs =  require('fs');
    const abi = JSON.parse(fs.readFileSync('../build/contracts/anchoringSC.json').toString());
    return abi.abi;
}

const account = '0x66d66805E29EaB59901f8B7c4CAE0E38aF31cb0e';
const contract = '0x243c5fd09E03C02a4f2e502320b9884e157200a1';
const factory = getFactory('http://localhost:8545',contract,getAbi(),account);

factory.methods.getStuff("key1").call().then((f) => {
    console.log('finished get :', f);
}).catch(err => {
    console.log(err);
});

