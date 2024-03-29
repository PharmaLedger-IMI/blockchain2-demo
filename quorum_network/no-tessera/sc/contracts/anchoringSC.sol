// SPDX-License-Identifier: MIT
pragma solidity >= 0.5 <= 0.7;
pragma experimental ABIEncoderV2;

contract anchoringSC {

    // error codes
    uint constant statusOK = 200;
    uint constant statusAddedConstSSIOK = 201;
    uint constant statusHashLinkOutOfSync = 100;
    uint constant statusCannotUpdateReadOnlyAnchor = 101;
    uint constant statusHashOfPublicKeyDoesntMatchControlString = 102;
    uint constant statusSignatureCheckFailed = 103;

    event InvokeStatus(uint indexed statusCode);

    struct AnchorValue {
        string newHashLinkSSI;
        string lastHashLinkSSI;
        string ZKPValue;
    }

    // store all anchors
    AnchorValue[] anchorStorage;
    //keep a mapping between anchor(keySSI) and it's versions
    mapping (string => uint[]) anchorVersions;

    //mapping between anchorID and controlString.
    mapping (string => bytes32) anchorControlStrings;

    //mapping for read only anchors
    mapping (string => bool) readOnlyAnchorVersions;

    mapping(string => string) stuffAdded;
    constructor() public {

    }

    function addStuff(string memory key, string memory value) public {
        stuffAdded[key] = value;
    }

    function getStuff(string memory key) public view returns(string memory) {
        return stuffAdded[key];
    }

    // public function
    function addAnchor(string memory anchorID, bytes32 controlString,
        string memory newHashLinkSSI, string memory ZKPValue, string memory lastHashLinkSSI,
        bytes memory signature, bytes memory publicKey) public {

        //check if thew anchorID can accept updates
        if (isAnchorReadOnly(anchorID))
        {
            //anchor is readonly, reject updates
            emit InvokeStatus(statusCannotUpdateReadOnlyAnchor);
            return;
        }

        int validateAnchorContinuityResult = validateAnchorContinuity(anchorID, lastHashLinkSSI, newHashLinkSSI);
        if (validateAnchorContinuityResult == 0)
        {
            //hash link are out of sync
            emit InvokeStatus(statusHashLinkOutOfSync);
            return;
        }

        if (validateAnchorContinuityResult == -1)
        {
            //anchor is new and we must check controlString
            if (isEmptyBytes32(controlString))
            {
                //allow only one record of this anchorID
                //this anchorID will not accept updates in the future
                createReadOnlyNewAnchorValueOnAddAnchor(anchorID, newHashLinkSSI,ZKPValue,lastHashLinkSSI);
                //all done, invoke ok status
                emit InvokeStatus(statusAddedConstSSIOK);
                return;
            }
            // add controlString to the mapping
            anchorControlStrings[anchorID] = controlString;
        }

        //validate hash of the publicKey
        if (!validatePublicKey(publicKey,anchorID))
        {
            emit InvokeStatus(statusHashOfPublicKeyDoesntMatchControlString);
            return;
        }

        //validate signature
        if (!validateSignature(anchorID, newHashLinkSSI,ZKPValue,lastHashLinkSSI, signature,publicKey))
        {
            emit InvokeStatus(statusSignatureCheckFailed);
            return;
        }

        createNewAnchorValueOnAddAnchor(anchorID, newHashLinkSSI,ZKPValue,lastHashLinkSSI);
        //all done, invoke ok status
        emit InvokeStatus(statusOK);
    }

    function createNewAnchorValueOnAddAnchor(string memory anchorID, string memory newHashLinkSSI,
        string memory ZKPValue, string memory lastHashLinkSSI) private
    {
        //create new anchor value
        AnchorValue memory anchorValue = buildAnchorValue(newHashLinkSSI,lastHashLinkSSI,ZKPValue);
        anchorStorage.push(anchorValue);
        uint versionIndex = anchorStorage.length - 1;
        //update number of versions available for that anchor
        anchorVersions[anchorID].push(versionIndex);

    }

    function createReadOnlyNewAnchorValueOnAddAnchor(string memory anchorID, string memory newHashLinkSSI,
        string memory ZKPValue, string memory lastHashLinkSSI) private
    {
        //for readonly anchor store the values in the same place as normal anchors
        //getVersions will provide information the same way, regardless of the anchorID type

        //create new anchor value
        AnchorValue memory anchorValue = buildAnchorValue(newHashLinkSSI,lastHashLinkSSI,ZKPValue);
        anchorStorage.push(anchorValue);
        uint versionIndex = anchorStorage.length - 1;
        //update number of versions available for that anchor
        anchorVersions[anchorID].push(versionIndex);
        // mark the anchorID as read only
        readOnlyAnchorVersions[anchorID] = true;
    }

    function validatePublicKey(bytes memory publicKey,string memory anchorID) private view returns (bool){
        return (sha256(publicKey) == anchorControlStrings[anchorID]);
    }

    function validateSignature(string memory anchorID,string memory newHashLinkSSI,string memory ZKPValue,
        string memory lastHashLinkSSI, bytes memory signature, bytes memory publicKey) private view returns (bool)
    {
        return calculateAddress(publicKey) == getAddressFromHashAndSig(anchorID, newHashLinkSSI, ZKPValue, lastHashLinkSSI, signature);
    }

    // calculate the ethereum like address starting from the public key
    function calculateAddress(bytes memory pub) private pure returns (address addr) {
        // address is 65 bytes
        // lose the first byte 0x04, use only the 64 bytes
        // sha256 (64 bytes)
        // get the 20 bytes
        bytes memory pubk = get64(pub);

        bytes32 hash = keccak256(pubk);
        assembly {
            mstore(0, hash)
            addr := mload(0)
        }
    }

    function get64(bytes memory pub) private pure returns (bytes memory)
    {
        //format 0x04bytes32bytes32
        bytes32 first32;
        bytes32 second32;
        assembly {
        //intentional 0x04bytes32 -> bytes32. We drop 0x04
            first32 := mload(add(pub, 33))
            second32 := mload(add(pub, 65))
        }

        return abi.encodePacked(first32,second32);
    }

    function getAddressFromHashAndSig(string memory anchorID,string memory newHashLinkSSI,string memory ZKPValue,
        string memory lastHashLinkSSI, bytes memory signature) private view returns (address)
    {
        //return the public key derivation
        return recover(getHashToBeChecked(anchorID,newHashLinkSSI,ZKPValue,lastHashLinkSSI), signature);
    }

    function recover(bytes32 hash, bytes memory signature) private pure returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(hash, v, r, s);
        }
    }

    function getHashToBeChecked(string memory anchorID,string memory newHashLinkSSI,string memory ZKPValue,
        string memory lastHashLinkSSI) private view returns (bytes32)
    {
        //use abi.encodePacked to not pad the inputs
        if (anchorVersions[anchorID].length == 0)
        {
            return sha256(abi.encodePacked(anchorID,newHashLinkSSI,ZKPValue));
        }
        return sha256(abi.encodePacked(anchorID,newHashLinkSSI,ZKPValue,lastHashLinkSSI));
    }

    // Used in addAnchor
    function isAnchorReadOnly(string memory anchorID) private view returns(bool)
    {
        return readOnlyAnchorVersions[anchorID];
    }

    // Used in addAnchor
    function validateAnchorContinuity(string memory anchorID, string memory lastHashLinkSSI, string memory newHashLinkSSI) private view returns (int)
    {
        if (anchorVersions[anchorID].length == 0)
        {
            //first anchor to be added
            return -1;
        }
        uint index = anchorVersions[anchorID][anchorVersions[anchorID].length-1];

        //can import StringUtils contract or compare hashes
        //hash compare seems faster
        if (sha256(bytes(anchorStorage[index].newHashLinkSSI)) == sha256(bytes(lastHashLinkSSI)))
        {
            //ensure we dont get double hashLinkSSI
            if (sha256(bytes(newHashLinkSSI)) == sha256(bytes(lastHashLinkSSI)))
            {
                //raise out of sync. the hashlinks should be different, except 1st anchor
                return 0;
            }
            //last hash link from contract is a match with the one passed
            return 1;
        }
        //hash link is out of sync. the last hash link stored doesnt match with the last hash link passed
        return 0;
    }

    function buildAnchorValue(string memory newHashLinkSSI, string memory lastHashLinkSSI, string memory ZKPValue) private pure returns (AnchorValue memory){
        return AnchorValue(newHashLinkSSI, lastHashLinkSSI, ZKPValue);
    }

    function copyAnchorValue(AnchorValue memory anchorValue) private pure returns (AnchorValue memory){
        return buildAnchorValue(anchorValue.newHashLinkSSI, anchorValue.lastHashLinkSSI, anchorValue.ZKPValue);
    }

    // public function
    function getAnchorVersions(string memory anchor) public view returns (AnchorValue[] memory) {
        if (anchorVersions[anchor].length == 0)
        {
            return new AnchorValue[](0);
        }
        uint[] memory indexList = anchorVersions[anchor];
        AnchorValue[] memory result = new AnchorValue[] (indexList.length);
        for (uint i=0;i<indexList.length;i++){
            result[i] = copyAnchorValue(anchorStorage[indexList[i]]);
        }

        return result;

    }

    function check() public view returns (int){
        return 5;
    }

    //utility functions
    function isEmptyBytes32(bytes32 data) private pure returns (bool)
    {
        return data[0] == 0;
    }

}
