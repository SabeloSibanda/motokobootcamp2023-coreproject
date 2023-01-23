import Principal "mo:base/Principal";
actor {
    // Define the Proposal struct
    type Proposal = {
        id : Int;
        text : Text;
        vote_for : [(Principal, Nat)];
        vote_against : [(Principal, Nat)];
        passed : Bool;
    };

    // Keep track of all proposals
    var proposals = [(Int, Proposal)][];
    var next_id = 1;

    // Keep track of MB token balance for each member
    var token_balances = {Principal : Nat}{};

    // Function to submit a proposal
    public shared({caller}) func submit_proposal(text : Text) : async {#Ok : Proposal; #Err : Text} {
        // Create a new proposal with the given text
        let proposal = Proposal(id : next_id, text : text, vote_for : [], vote_against : [], passed : false);
        // Add the proposal to the list of proposals
        proposals.push((next_id, proposal));
        // Increment the next proposal id
        next_id += 1;
        return #Ok(proposal);
    };

    // Function to vote on a proposal
    public shared({caller}) func vote(proposal_id : Int, yes_or_no : Bool) : async {#Ok : (Nat, Nat); #Err : Text} {
        // Check if the caller has at least 1 MB token
        if (token_balances[caller] == null || token_balances[caller] < 1) {
            return #Err("You must have at least 1 MB token to vote");
        }

        // Find the proposal
        let proposal = proposals.find(x => x.0 == proposal_id);
        if (proposal == null) {
            return #Err("Proposal not found");
        }

        // Add the vote to the appropriate list
        let vote_list = yes_or_no ? proposal.vote_for : proposal.vote_against;
        vote_list.push((caller, token_balances[caller]));

        // Check if the proposal has passed or failed
        let vote_for_power = vote_list.reduce(0, (acc, x) => acc + x.1);
        if (vote_for_power >= 100) {
            proposal.passed = true;
        }
        let vote_against_power = proposal.vote_against.reduce(0, (acc, x) => acc + x.1);
        if (vote_against_power >= 100) {
            proposal.passed = false;
        }

        return #Ok((vote_for_power, vote_against_power));
    };

    // Function to get a specific proposal
    public query func get_proposal(id : Int) : async ?Proposal {
        return proposals.find(x => x.0 == id);
    };
    
    // Function to get all proposals
    public query func get_all_proposals() : async [(Int, Proposal)][] {
        return proposals;
    };
};
