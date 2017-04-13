pragma solidity ^0.4.8;
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../../contracts/NormCorpus.sol";
import "../../contracts/Legislator.sol";
import "../../contracts/example/norms/AutocraticVoting.sol";

contract NormCorpusTest {
    Legislator public legislator;
    NormCorpus public registry;

    function beforeEach() {
      registry = new NormCorpus();
      legislator= new Legislator();
    }

    function testThawedInsert() {
      registry.insert(legislator);
      Assert.isTrue(isInRegister(legislator), "Insertion of Legislator failed for owner");
    }

    //This is a low level test to check if 'valid' caller isValid works
    function testWhenRegistryOwnerBurned_ThenInsertNotPossible() {
        registry = new NormCorpus();
        //legislator.burnOwner();
        //registry.burnOwner();
        registry.insert(legislator);
        Assert.isFalse(isInRegister(legislator), "Insertion of Legislator failed after burning owner");
    }

    /** helpers **/
    function isInRegister(address addr) constant returns (bool) {
       return registry.contains(addr);
    }
}
