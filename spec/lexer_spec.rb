require "lexer"
require "token"

RSpec.describe Lexer do
  def expect_tokens(tokens, expected)
    tokens.each_with_index do |token, index|
      expect(token).to be_a Token
      expect(token).to eq expected[index]
    end
  end
  it "tokenizes a tag" do
    lexer = Lexer.new("/div")
    expected = [
      TagToken.new("/div", 0)
    ]
    expect_tokens(lexer.lex, expected)
  end

  it "tokenizes a tag with attributes on a new line" do
    lexer = Lexer.new("/div\n  class='foo'")
    expected = [
      TagToken.new("/div class='foo'", 0)
    ]

    expect_tokens(lexer.lex, expected)
  end

  fit "tracks indents accurately" do
    src = <<~SLASHDOWN
      /ul
        // This is a comment
        /li
          class='foo'

          this is a paragraph

        /li
    SLASHDOWN
    lexer = Lexer.new(src)
    expected = [
      TagToken.new("/ul", 0),
      TagToken.new("/li class='foo'", 1),
      MarkdownToken.new("this is a paragraph", 2),
      TagToken.new("/li", 1)
    ]

    expect_tokens(lexer.lex, expected)
  end
end
