import DAO "path/to/DAO/canister";
import Map "mo:std/Map";

actor {
    public stateful var text : Text;
    public stateful var current_proposal : ?Proposal;

    public shared func update_text(text : Text) : async {
        self.text = text;
    }

    public shared func display_text() : async {
        return text;
    }

    public shared({caller}) func create_proposal(text : Text) : async {#Ok : Proposal; #Err : Text} {
        let proposal = await DAO.submit_proposal(text);
        current_proposal = proposal;
        return proposal;
    }

    public shared({caller, tokens}) func vote(yes_or_no : Bool) : async {#Ok : (Nat, Nat); #Err : Text} {
        if current_proposal == null {
            return #Err("No proposal to vote on")
        }
        let proposal_id = current_proposal.id;
        return DAO.vote(proposal_id, yes_or_no);
    }

};

