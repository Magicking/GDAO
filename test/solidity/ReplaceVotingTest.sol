pragma solidity ^0.4.8;
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../../contracts/NormCorpus.sol";
import "../../contracts/GDAO.sol";
import "../../contracts/Legislator.sol";
import "../../contracts/example/norms/AutocraticVoting.sol";
import "../../contracts/example/norms/SimpleMajorityVoting.sol";
import "../../contracts/example/norms/SubstituteVoting.sol";
import "../../contracts/example/proposals/DummyProposal.sol";

contract ReplaceVotingTest{
    LegislatorInterface legislator;
    SubstituteVoting norm;
    NormCorpus normCorpus;
    SimpleMajorityVoting newVoting;

    function beforeEach(){
      legislator = LegislatorInterface(DeployedAddresses.Legislator());
      normCorpus = NormCorpus(DeployedAddresses.NormCorpus());
      var proxy = GDAO(DeployedAddresses.GDAO());
      newVoting = new SimpleMajorityVoting(proxy);
      norm = new SubstituteVoting(legislator, newVoting, proxy);
      normCorpus.burnOwner();
      Legislator(legislator).burnOwner();
    }

    function testWhenSubstituteVotingIsEnacted_ThenNewVoting(){
      var proposal = new DummyProposal(norm);
      legislator.proposeNorm(proposal);
      bool result = legislator.enactNorm(proposal);
      Assert.isFalse(result, "Cant be enacted, no vote has been casted");
      AutocraticVoting oldNorm = AutocraticVoting(legislator.getVoting());
      oldNorm.vote(proposal);
      result = legislator.enactNorm(proposal);
      Assert.isTrue(result, "Must be enacted, voted for");
      Assert.isTrue(normCorpus.contains(norm), "New norm must be in corpus");
      norm.execute();
      Assert.isFalse(normCorpus.contains(norm), "Norm had to remove itself");
      Assert.isTrue(normCorpus.contains(newVoting), "SimpleMajorityVoting is now a norm");
      Assert.isTrue(address(legislator.getVoting())== address(newVoting), "new Voting must have been installed");
      legislator.proposeNorm(proposal);
      newVoting.vote(proposal);
      newVoting.vote(proposal);
      var nbVoters = newVoting.getVotersNumber();
      Assert.equal(nbVoters, 2, "Should have 2 voters"); //First test for SimpleMajorityVoting
      //Assert.isFalse(normCorpus.contains(oldNorm), "Old norm must be gone");*/
    }


}
