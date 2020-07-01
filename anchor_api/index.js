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
    const instance = await DataAnchor.new(req.body.name, req.body.hash, JSON.stringify(req.body.metadata), {from: account});
    const data = await instance.getData.call();
    await res.json({
        anchorId: data[0],
        name: data[1],
        hash: data[2],
        metadata: JSON.parse(data[3]),
    });
});

app.get('/data_anchors/:anchorId', async (req, res) => {
    const instance = await DataAnchor.at(req.params.anchorId);
    const data = await instance.getData.call();
    await res.json({
        anchorId: data[0],
        name: data[1],
        hash: data[2],
        metadata: JSON.parse(data[3]),
    });
});

app.put('/data_anchors/:anchorId', async (req, res) => {
    console.log(req.body);
    const instance = await DataAnchor.at(req.params.anchorId);
    const result = await instance.setData.sendTransaction(req.body.name, JSON.stringify(req.body.metadata), {from: account});
    const data = await instance.getData.call();
    await res.json({
        anchorId: data[0],
        name: data[1],
        hash: data[2],
        metadata: JSON.parse(data[3]),
    });
});

// starting the server
app.listen(8080, () => {
  console.log('listening on port 8080');
});
