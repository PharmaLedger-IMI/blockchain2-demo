// importing the dependencies
// defining the Express app
require('dotenv').config();

const express = require('express')
    , config = require('config')
    , bodyParser = require('body-parser')
    , cors = require('cors')
    , helmet = require('helmet')
    , morgan = require('morgan')
    , Web3 = require('web3')
    , app = express()
    , web3 = new Web3(config.get('web3.provider'))
    , DataAnchorArtifact = require('./build/contracts/DataAnchor.json')
    , TruffleContract = require("@truffle/contract")
    , DataAnchor = TruffleContract(DataAnchorArtifact)
    , account = config.get('web3.account');

DataAnchor.setProvider(web3.currentProvider);
DataAnchor.autoGas = true;
DataAnchor.defaults({
  from: account
})

// adding Helmet to enhance your API's security
app.use(helmet());

// using bodyParser to parse JSON bodies into JS objects
app.use(bodyParser.json());

// enabling CORS for all requests
app.use(cors());

// adding morgan to log HTTP requests
app.use(morgan('combined'));

// defining an endpoint to return status
app.get('/', (req, res) => {
    let isListening = false
        , accounts = [];

    web3.eth.getAccounts()
        .then((_accounts) => {
            isListening = true;
            accounts = _accounts
        })
        .catch(console.error)
        .then(() => {
            res.json({provider: config.get('web3.provider'), account: config.get('web3.account'), isListening: isListening, accounts: accounts})
        });
});

app.post('/data_anchors', async (req, res) => {

    try {
        let unlocked = false;

        if (config.get('web3.password') && !unlocked) {
            console.log('>> Unlocking account ' + account + ' with password ' + config.get('web3.password'));
            unlocked = await web3.eth.personal.unlockAccount(account, config.get('web3.password'), 36000);
        }

        const instance = await DataAnchor.new(req.body.name, req.body.hash, JSON.stringify(req.body.metadata), {from: account});
        const data = await instance.getData.call();

        if (config.get('web3.password') && unlocked) {
            console.log('>> Locking account ' + account);
            unlocked = await web3.eth.personal.lockAccount(account);
        }

        await res.json({
            anchorId: data[0],
            name: data[1],
            hash: data[2],
            metadata: JSON.parse(data[3]),
        });
    } catch (error) {
        console.log(error)
        res.json({});
    }
});

app.get('/data_anchors/:anchorId', async (req, res) => {
    try {
        let unlocked = false;

        if (config.get('web3.password') && !unlocked) {
            console.log('>> Unlocking account ' + account + ' with password ' + config.get('web3.password'));
            unlocked = await web3.eth.personal.unlockAccount(account, config.get('web3.password'), 36000);
        }

        const instance = await DataAnchor.at(req.params.anchorId);
        const data = await instance.getData.call();

        if (config.get('web3.password') && unlocked) {
            console.log('>> Locking account ' + account);
            unlocked = await web3.eth.personal.lockAccount(account);
        }

        await res.json({
            anchorId: data[0],
            name: data[1],
            hash: data[2],
            metadata: JSON.parse(data[3]),
        });
    } catch (error) {
        console.log(error)
        res.json({});
    }
});

app.put('/data_anchors/:anchorId', async (req, res) => {
    try {
        let unlocked = false;

        if (config.get('web3.password') && !unlocked) {
            console.log('>> Unlocking account ' + account + ' with password ' + config.get('web3.password'));
            unlocked = await web3.eth.personal.unlockAccount(account, config.get('web3.password'), 36000);
        }

        const instance = await DataAnchor.at(req.params.anchorId);
        const result = await instance.setData.sendTransaction(req.body.name, JSON.stringify(req.body.metadata), {from: account});
        const data = await instance.getData.call();

        if (config.get('web3.password') && unlocked) {
            console.log('>> Locking account ' + account);
            unlocked = await web3.eth.personal.lockAccount(account);
        }

        await res.json({
            anchorId: data[0],
            name: data[1],
            hash: data[2],
            metadata: JSON.parse(data[3]),
        });
    } catch (error) {
        console.log(error)
        res.json({error: error});
    }
});

// starting the server
app.listen(8080, () => {
  console.log('listening on port 8080');
});
