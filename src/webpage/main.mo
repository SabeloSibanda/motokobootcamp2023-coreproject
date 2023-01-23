actor {
    public var text: Text;

    public shared func update_text(new_text: Text) : async {
        text = new_text;
    }
};
