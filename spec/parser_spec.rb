require "parser"

RSpec.describe Parser do
  let(:tokens) { [Token.new(:TAG, "div", 0), Token.new(:MARKDOWN, "This is content", 1)] }
  let(:parser) { Parser.new(tokens) }

  describe "#initialize" do
    it "initializes with an array of tokens" do
      expect(parser.instance_variable_get(:@tokens)).to eq(tokens)
    end

    it "sets the cursor to 0" do
      expect(parser.instance_variable_get(:@cursor)).to eq(0)
    end
  end

  describe "#parse" do
    let(:tokens) do
      [
        Token.new(:TAG, "div", 0),
        Token.new(:SELECTOR, ".container", 1),
        Token.new(:TAG, "p", 2),
        Token.new(:MARKDOWN, "This is content", 2)
      ]
    end

    it "correctly manages hierarchy and children" do
      nodes = Parser.new(tokens).parse
      div_node = nodes.first

      expect(div_node.type).to eq(:TAG)
      expect(div_node.identifier).to eq("div")
      expect(div_node.classes).to include("container")
      expect(div_node.children.length)

      # TODO: Finish this
    end
  end
end
