import Web "mo:web";

const dao_url = "<url of the DAO canister>"

// A function to display the current text on the page
func show_text() {
    let text = Web.get("/text").unwrap();
    Web.html("<div id='text'>" + text + "</div>");
}

// A function to display the form to submit a proposal
func show_submit_form() {
    let form = Web.html("<form id='submit_form'>" +
        "<textarea id='text' name='text'></textarea>" +
        "<input type='submit' value='Submit'>" +
    "</form>");
    form.onsubmit = async () => {
        let text = form.elements["text"].value;
        let response = await Web.fetch(dao_url + "/submit_proposal", {
            method: "POST",
            body: JSON.stringify({text: text})
        });
        let result = JSON.parse(response.unwrap());
        if (result.Err != null) {
            Web.html("<div>Error: " + result.Err + "</div>");
        } else {
            Web.html("<div>Proposal submitted! ID: " + result.Ok.id + "</div>");
        }
        return false;
    };
}

// A function to display the form to vote on a proposal
func show_vote_form(proposal_id : Int) {
    let form = Web.html("<form id='vote_form'>" +
       

