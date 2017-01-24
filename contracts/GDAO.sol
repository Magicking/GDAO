pragma solidity ^0.4.4;

contract Legitimate {
    Legislation public legalRegistry;
    address public owner; // for a thawing phase

    function Legitime(){
        owner = msg.sender;
    }

    modifier legit {
        if (address(legalRegistry) != 0x0 && legalRegistry.contains(address(this))){
            _;
        }
        else if (owner !=  0xdeadbeef && msg.sender == owner) {

            _;
        }
        else NotLegit(address(this));
    }
    event NotLegit(address);

    modifier callerLegit {

        if (address(legalRegistry) != 0x0 && legalRegistry.contains(msg.sender)){
            _;
        }
        else if (owner !=  0xdeadbeef && msg.sender == owner) {
            _;
        }
        else CallerNotLegit(msg.sender);
    }

    modifier onlyOwner {
        if (owner !=msg.sender) throw;
        _;
    }

    event CallerNotLegit(address);
    event Msg(string mes);

    function getOwner() external returns(address){
        return owner;
    }

    function burnOwner() callerLegit{
        owner = 0xdeadbeef; //thawing phase is over
    }

}

contract ATest{
    Legislator public legislator;
    Legislation public registry;
    DictatorVoting public voting;
    SubstituteVoting public proposal;


    function ATest(){
        log0("caller is owner");
        registry = new Legislation();
        legislator= new Legislator();
        registry.burnOwner();
        registry.insert(legislator); // the legislator is a legit contract

    }
    function step1(){
        legislator.setRegistry(registry);
        voting = new DictatorVoting();
        legislator.setVoting(voting);

    }
    function step2(){

        proposal = new SubstituteVoting(legislator, new NaiveMajorityVoting());
        legislator.proposeLaw(proposal, 200);
    }
    function step3(){
        voting.vote(1);
        legislator.enactLaw(1);
        proposal.execute();

    }

    function assertVotingChanged() constant returns (bool){
        address a =address(voting);
        LegitimateVoting v = legislator.getVoting();
        address b = address(v);
        return a != b;
    }
}


contract Legislation is Legitimate{

    mapping(address => bool) public isLegit;
    uint public numberOfLaws;


    function Legislation (){
        legalRegistry = this;
        owner= msg.sender;
    }

    function insert(address _contract) callerLegit {
        isLegit[_contract]=true;
        numberOfLaws++;
    }


    function remove(address _contract) callerLegit {
        isLegit[_contract]=false;
        numberOfLaws--;
    }

    function contains(address _contract) external constant returns(bool){
        return isLegit[_contract];
    }


}

contract Legislator is Legitimate{


    LegitimateVoting public voting ;
    LegitimateLaw[] public proposals;

    function Legislator (){
        owner= msg.sender;
    }

    function setRegistry(Legislation _registry) callerLegit legit external{
        legalRegistry = _registry;
    }

    function setVoting(LegitimateVoting _voting) callerLegit legit external{
        voting = _voting;
    }
    function getVoting() public returns (LegitimateVoting){
        return voting;
    }

    function proposeLaw(LegitimateLaw _proposal, uint _deadline) callerLegit legit external{
        proposals.push(_proposal);
        voting.propose(proposals.length, _deadline);
    }

    function enactLaw(uint _proposalNumber)  external{
        if (!voting.isPassed(_proposalNumber)) throw;
        legalRegistry.insert(proposals[_proposalNumber - 1]);
        delete proposals[_proposalNumber - 1];

    }

}

contract LegitimateVoting is Legitimate {
    function vote(uint _proposalNumber) external;
    function propose(uint _proposalNumber, uint _deadline) external;
    function isPassed(uint _proposalNumber) external constant returns (bool);
}

contract DictatorVoting is LegitimateVoting{

    mapping (uint => bool) passed;
    function DictatorVoting(){
        owner = msg.sender;
    }

    function vote(uint _proposalNumber) external{
        if (msg.sender != owner) throw;
        passed[_proposalNumber] = true;
    }

    function propose(uint _proposalNumber, uint _deadline) external{
        passed[_proposalNumber]=false;
    }

    function isPassed(uint _proposalNumber) external constant returns (bool){
        return passed[_proposalNumber];
    }

}
contract NaiveMajorityVoting is LegitimateVoting{
    uint voters = 3;
    mapping (uint => uint) votes;

    function DictatorVoting(){
        owner = msg.sender;
    }

    function vote(uint _proposalNumber) external{
        votes[_proposalNumber] ++;

    }

    function propose(uint _proposalNumber, uint _deadline) external{
        votes[_proposalNumber]=0;
    }

    function isPassed(uint _proposalNumber) external constant returns (bool){
        return votes[_proposalNumber] > voters;
    }

}


contract LegitimateLaw is Legitimate{
  string public description;
}

contract SubstituteVoting is LegitimateLaw{

    LegitimateVoting newVoting;
    Legislator legislator;

    function SubstituteVoting(Legislator _legislator, LegitimateVoting _newvoting){
        description = "substitute the court by a simple majority vote of party members";
        newVoting = _newvoting;
        legislator = _legislator;
    }

    function execute() legit external{
        legislator.setVoting(newVoting);
        legalRegistry.remove(this);
        suicide(legislator);
    }

}