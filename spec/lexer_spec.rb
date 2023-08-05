require "spec_helper"

RSpec.describe Slashdown::Lexer do
  it "raises an error if source code is nil" do
    expect { Slashdown::Lexer.new(nil) }.to raise_error(ArgumentError, "Source code cannot be nil")
  end

  it "raises an error if source code is not a string" do
    expect { Slashdown::Lexer.new(123) }.to raise_error(ArgumentError, "Source code must be a string")
  end

  it "can lex a simple tag" do
    lexer = Slashdown::Lexer.new("/div")
    tokens = lexer.tokens
    expect(tokens).to eq [
      Slashdown::Token.new(:TAG, "div", 0)
    ]
  end

  it "can lex a blank tag with a class" do
    lexer = Slashdown::Lexer.new("/ .my-class")
    tokens = lexer.tokens
    expect(tokens).to eq [
      Slashdown::Token.new(:TAG, "", 0),
      Slashdown::Token.new(:SELECTOR, ".my-class", 0)
    ]
  end

  it "can lex multiple chained selectors" do
    lexer = Slashdown::Lexer.new("/section #hero.grid")
    tokens = lexer.tokens
    expect(tokens).to eq [
      Slashdown::Token.new(:TAG, "section", 0),
      Slashdown::Token.new(:SELECTOR, "#hero", 0),
      Slashdown::Token.new(:SELECTOR, ".grid", 0)
    ]
  end

  describe "attributes" do
    it "works" do
      lexer = Slashdown::Lexer.new('/div data-foo="bar baz"')
      tokens = lexer.tokens
      expect(tokens).to eq [
        Slashdown::Token.new(:TAG, "div", 0),
        Slashdown::Token.new(:ATTRIBUTE, 'data-foo="bar baz"', 0)
      ]
    end

    it "can have both classes and attributes" do
      lexer = Slashdown::Lexer.new('/div .my-class data-foo="bar baz"')
      tokens = lexer.tokens
      expect(tokens).to eq [
        Slashdown::Token.new(:TAG, "div", 0),
        Slashdown::Token.new(:SELECTOR, ".my-class", 0),
        Slashdown::Token.new(:ATTRIBUTE, 'data-foo="bar baz"', 0)
      ]
    end

    it "can lex attributes on a new line" do
      src = <<~SD
        /div
          data-foo="bar baz"
          This is content
      SD

      lexer = Slashdown::Lexer.new(src)
      tokens = lexer.tokens
      expect(tokens).to eq [
        Slashdown::Token.new(:TAG, "div", 0),
        Slashdown::Token.new(:ATTRIBUTE, 'data-foo="bar baz"', 2),
        Slashdown::Token.new(:MARKDOWN, "This is content", 2)
      ]
    end
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

    lexer = Slashdown::Lexer.new(src)
    tokens = lexer.tokens
    expect(tokens).to eq [
      Slashdown::Token.new(:TAG, "ul", 0),
      Slashdown::Token.new(:SELECTOR, ".list", 0),
      Slashdown::Token.new(:TAG, "li", 2),
      Slashdown::Token.new(:TAG, "li", 2),
      Slashdown::Token.new(:ATTRIBUTE, 'data-foo="bar baz"', 4),
      Slashdown::Token.new(:TAG, "span", 4),
      Slashdown::Token.new(:TAG, "footer", 0),
      Slashdown::Token.new(:BLANK, nil, nil),
      Slashdown::Token.new(:MARKDOWN, "This is outdented content", 2)
    ]
  end

  it "can lex a tag with text content" do
    src = <<~SD
      /div = This is text
    SD
    lexer = Slashdown::Lexer.new(src)
    tokens = lexer.tokens
    expect(tokens).to eq [
      Slashdown::Token.new(:TAG, "div", 0),
      Slashdown::Token.new(:TEXT, "This is text", 0)
    ]
  end
end
