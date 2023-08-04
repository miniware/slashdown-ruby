require_relative "spec_helper"

RSpec.describe Parser do
  it "coerces blank tags to divs" do
    tokens = [Token.new(:TAG, "", 0)]
    tag_node = Parser.new(tokens).ast.first

    expect(tag_node.identifier).to eq("div")
  end

  it "correctly manages hierarchy and children" do
    # rubocop:disable Layout/ArrayAlignment
    tokens = [
      Token.new(:TAG, "section", 0),
        Token.new(:ATTRIBUTE, "foo='bar'", 1),
        Token.new(:TAG, "h1", 1),
          Token.new(:TEXT, "Hello World!", 2),
        Token.new(:MARKDOWN, "This is content", 1),
        Token.new(:BLANK, nil, nil),
        Token.new(:MARKDOWN, "This is more content", 1),
      Token.new(:TAG, "footer", 0),
        Token.new(:TEXT, "Goodnight Moon.", 1)
    ]
    # rubocop:enable Layout/ArrayAlignment

    ast = Parser.new(tokens).ast

    section, footer = ast

    expect(section.identifier).to eq("section")
    expect(section.all_attributes).to include("foo='bar'")
    expect(section.children.length).to eq(2)

    expect(footer.identifier).to eq("footer")
    expect(footer.children.length).to eq(1)
    expect(footer.children.first.content).to eq("Goodnight Moon.")

    h1, md = section.children
    expect(h1.type).to eq(:TAG)
    expect(h1.identifier).to eq("h1")
    expect(h1.children.length).to eq(1)

    expect(md.content).to eq("This is content\n\nThis is more content")
  end
end
