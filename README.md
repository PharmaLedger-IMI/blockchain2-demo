# blockchain2-demo

This repository contains a PoC of Anchor APIs using the Quorum blockchain network. 

* API documentation can be found here [Swagger](anchor_api/swagger.yaml)
The actual implementation is designed using Node.js ecosystem.
The web service will expose operations in which, an anchor defined as JSON, will be stored, updated, fetched or removed. 
All operations are executed over the Quorum blockchain network using a smart contract. 
The smart contract are intended to be implemented using Solidity and Truffle framework [47]. U
sing the demo Anchor API, one can store a data anchor (generating a proof of existence receipt) to prove the existence of some data at some point in time using the Quorum blockchain. 
Following operations will be exposed by the PoC

* POST /data_anchors - Create a new data anchor 
* GET - /data_anchors /{anchorId} - Get an anchor by its identifier 
* PUT - /data_anchors /{anchorId} - Update an anchor by its identifier 

