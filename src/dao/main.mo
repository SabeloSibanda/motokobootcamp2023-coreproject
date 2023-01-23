import Principal "mo:base/Principal";

actor DAO {
    type Proposal = {
        id: Int;
        text: Text;
        yes_votes: Nat;
        no_votes: Nat;
        voters: Map<Principal, Nat>
    };

    public var proposals: Map<Int, Proposal>
    public var webpage_canister: WebpageCanister;

    public shared({caller, tokens: Nat}) func submit_proposal(text: Text) : async {
        let id = proposals.count();
        let proposal = Proposal(id: id, text: text, yes_votes: 0, no_votes: 0, voters: {});
        proposals.set(id, proposal);
        return #Ok(proposal);
    }

    public shared({caller, tokens: Nat}) func vote(proposal_id: Int, yes_or_no: Bool) : async {
        let proposal = proposals.get(proposal_id);
        if (proposal == null) {
            return #Err("Invalid proposal ID");
        }
        if (tokens < 1_000_000) {
            return #Err("You must hold at least 1 MB token to vote");
        }
        if (proposal.voters.contains(caller)) {
            return #Err("You have already voted on this proposal");
        }
        proposal.voters.set(caller, tokens);
        if (yes_or_no) {
            proposal.yes_votes += tokens;
        } else {
            proposal.no_votes += tokens;
        }
        if (proposal.yes_votes >= 100_000_000) {
            // Pass the proposal
            webpage_canister.update_text(proposal.text);
            return #Ok("Proposal passed");
        } else if (proposal.no_votes >= 100_000_000) {
            // Reject the proposal
            return #Ok("Proposal rejected");
        } else {
            return #Ok("Vote recorded");
        }
    }

    public query func get_proposal(id: Int) : async ?Proposal {
        return proposals.get(id);
    }

    public query func get_all_proposals() : async [(Int, Proposal)] {
        return proposals.toList();
    }
}
