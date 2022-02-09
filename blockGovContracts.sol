pragma solidity >=0.7.0 <0.9.0;
import "https://github.com/pipermerriam/ethereum-datetime/blob/master/contracts/api.sol";

contract GovernmentProcurement{
    uint procurementId;
    mapping (uint => Procurement) procurements;
    address public govInstitution;
    struct Date{
        uint year;
        uint month;
        uint day;
    }

    struct OffersDeadline{
        Date startDate;
        Date endDate;
    }

    struct VotingDeadline{
        Date startDate;
        Date endDate;
    }
    struct Procurement{
        address payable govWallet;
        uint256 budget;
        uint256 id;
        OffersDeadline offersDeadline;
        VotingDeadline votingDeadline;
        string[] requirements;
    }

    constructor () public{
        procurementId = 0;
        govInstitution = msg.sender;
    }

    function getprocurementId() public view returns (uint) {
        return procurementId;
    }
    function submitProcurement(address payable govWallet, uint256 budget, string[] memory requirements, OffersDeadline memory offerDeadline, VotingDeadline memory votingDeadline) public {
        procurements[procurementId] = Procurement(govWallet, budget, procurementId, offerDeadline, votingDeadline, requirements);
        procurementId++;
    }

    function getProcurements() public view returns (Procurement[] memory) {
        Procurement [] memory result = new Procurement[](procurementId);
        for (uint i = 0; i < procurementId; i++) {
            result[i] = procurementId[i];
        }
        return result;
    }

    function getProcurement(address addr) public view returns (Procurement memory) {
        return procurements[addr];
    }

}

contract BusinessOffers{
    GovernmentProcurement govProc;
    struct Business{
        address payable businessWallet;
        Offer[] offers; 
    }
    mapping(address => Business) businessToOffers;
    uint offerId;
    struct Offer {        
        uint256 id;
        uint256 priceOffered;
        uint256 procurementId;
    }
    constructor () public{
        offerId = 0;
        govProc = GovernmentProcurement();
    }
    Offer[] offers;
    mapping (uint => Offer) idToOffers;
    function submitOffer(address procurementId, uint priceOffer) public payable{
        require(govProc.getProcurement(procurementId).budget != 0, "Procurement has not been submitted yet");
        currentYear = getCurrentYear(block.timestamp);
        currentMonth = getCurrentMonth(block.timestamp);
        currentDay = getCurrentDay(block.timestamp);
        offers.push(Offer(offerId, priceOffer, procurementId));
        offerId++;
    }

}
contract Ballot {
   
    struct Voter {
        uint weight;
        bool voted; 
        address delegate;
        uint vote; 
    }

    struct Proposal {
       
        bytes32 name; 
        uint voteCount;
    }

    address public chairperson;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;


    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {

            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }
    
    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }


    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function winnerName() public view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }
}
