pragma solidity ^0.4.8;

import "./AbstractNormCorpus.sol";

contract NormCorpus is AbstractNormCorpus {

    mapping(address => bool) public isNorm;
    uint public numberOfNorms;

    function NormCorpus() {
        normCorpus = this;
    }

    function insert(address _contract) isCallerValid {
        isNorm[_contract] = true;
        numberOfNorms = numberOfNorms + 1;
    }

    function remove(address _contract) isCallerValid {
        delete isNorm[_contract];
        numberOfNorms = numberOfNorms - 1;
    }

    function contains(address _contract) external constant returns(bool) {
        return isNorm[_contract];
    }
}
