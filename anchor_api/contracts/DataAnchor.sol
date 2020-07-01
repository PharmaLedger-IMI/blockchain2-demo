pragma solidity >=0.4.21 <0.7.0;

contract DataAnchor {
    string public name;
    string public hash;
    string public metadata;

    constructor(string memory _name, string memory _hash, string memory _metadata) public {
        name = _name;
        hash = _hash;
        metadata = _metadata;
    }

    function setData(string memory _name, string memory _metadata) public {
        name = _name;
        metadata = _metadata;
    }

    function getData() public view returns (address, string memory, string memory, string memory) {
        return (address(this), name, hash, metadata);
    }
}