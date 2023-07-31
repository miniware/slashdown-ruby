require "spec_helper"
require "lexer"

RSpec.describe Lexer do
  it "raises an error if source code is nil" do
    expect { Lexer.new(nil) }.to raise_error(ArgumentError, "Source code cannot be nil")
  end

  it "raises an error if source code is not a string" do
    expect { Lexer.new(123) }.to raise_error(ArgumentError, "Source code must be a string")
  end

  it "can lex a simple tag" do
    lexer = Lexer.new("/div")
    tokens = lexer.tokens
    expect(tokens).to eq [
      Token.new(:TAG, "div", 0)
    ]
  end

  it "can lex a blank tag with a class" do
    lexer = Lexer.new("/ .my-class")
    tokens = lexer.tokens
    expect(tokens).to eq [
      Token.new(:TAG, "div", 0),
      Token.new(:SELECTOR, ".my-class", 0)
    ]
  end

  it "can lex multiple chained selectors" do
    lexer = Lexer.new("/section #hero.grid")
    tokens = lexer.tokens
    expect(tokens).to eq [
      Token.new(:TAG, "section", 0),
      Token.new(:SELECTOR, "#hero", 0),
      Token.new(:SELECTOR, ".grid", 0)
    ]
  end

  it "can lex a tag with an attribute" do
    lexer = Lexer.new('/div data-foo="bar baz"')
    tokens = lexer.tokens
    expect(tokens).to eq [
      Token.new(:TAG, "div", 0),
      Token.new(:ATTRIBUTE, 'data-foo="bar baz"', 0)
    ]
  end

  it "can lex a tag with a class and an attribute" do
    lexer = Lexer.new('/div .my-class data-foo="bar baz"')
    tokens = lexer.tokens
    expect(tokens).to eq [
      Token.new(:TAG, "div", 0),
      Token.new(:SELECTOR, ".my-class", 0),
      Token.new(:ATTRIBUTE, 'data-foo="bar baz"', 0)
    ]
  end

  it "can lex a tag with attributes on a new line" do
    src = <<~SD
      /div
        data-foo="bar baz"

        This is content
    SD

    lexer = Lexer.new(src)
    tokens = lexer.tokens
    expect(tokens).to eq [
      Token.new(:TAG, "div", 0),
      Token.new(:ATTRIBUTE, 'data-foo="bar baz"', 1),
      Token.new(:BLANK, nil, nil),
      Token.new(:MARKDOWN, "This is content", 1)
    ]
  end

  it "tracks indentation properly" do
    src = <<~SD
      /ul .list
        /li
      // This is a comment which should be ignored
        /li
          data-foo="bar baz"
          /span
      /footer

        This is outdented content
    SD

    lexer = Lexer.new(src)
    tokens = lexer.tokens
    expect(tokens).to eq [
      Token.new(:TAG, "ul", 0),
      Token.new(:SELECTOR, ".list", 0),
      Token.new(:TAG, "li", 1),
      Token.new(:TAG, "li", 1),
      Token.new(:ATTRIBUTE, 'data-foo="bar baz"', 2),
      Token.new(:TAG, "span", 2),
      Token.new(:TAG, "footer", 0),
      Token.new(:BLANK, nil, nil),
      Token.new(:MARKDOWN, "This is outdented content", 1)
    ]
  end

  it "can lex a tag with text content" do
    src = <<~SD
      /div = This is text
    SD
    lexer = Lexer.new(src)
    tokens = lexer.tokens
    expect(tokens).to eq [
      Token.new(:TAG, "div", 0),
      Token.new(:TEXT, "This is text", 0)
    ]
  end
end
