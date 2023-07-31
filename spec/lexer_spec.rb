require "spec_helper"
require "lexer"

RSpec.describe Lexer do
  it "can lex a simple tag" do
    lexer = Lexer.new("/div")
    tokens = lexer.lex
    expect(tokens).to eq [
      [:TAG, "div"]
    ]
  end

  it "can lex a blank tag with a class" do
    lexer = Lexer.new("/ .my-class")
    tokens = lexer.lex
    expect(tokens).to eq [
      [:TAG, ""],
      [:SELECTOR, ".my-class"]
    ]
  end

  it "can lex multiple chained selectors" do
    lexer = Lexer.new("/section #hero.grid")
    tokens = lexer.lex
    expect(tokens).to eq [
      [:TAG, "section"],
      [:SELECTOR, "#hero"],
      [:SELECTOR, ".grid"]
    ]
  end

  it "can lex a tag with an attribute" do
    lexer = Lexer.new('/div data-foo="bar baz"')
    tokens = lexer.lex
    expect(tokens).to eq [
      [:TAG, "div"],
      [:ATTRIBUTE, 'data-foo="bar baz"']
    ]
  end

  it "can lex a tag with a class and an attribute" do
    lexer = Lexer.new('/div .my-class data-foo="bar baz"')
    tokens = lexer.lex
    expect(tokens).to eq [
      [:TAG, "div"],
      [:SELECTOR, ".my-class"],
      [:ATTRIBUTE, 'data-foo="bar baz"']
    ]
  end

  it "can lex a tag with attributes on a new line" do
    src = <<~SD
      /div
        data-foo="bar baz"

        This is content
    SD

    lexer = Lexer.new(src)
    tokens = lexer.lex
    expect(tokens).to eq [
      [:TAG, "div"],
      [:INDENT, 1],
      [:ATTRIBUTE, 'data-foo="bar baz"'],
      [:BLANK],
      [:MARKDOWN, "This is content"]
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
    tokens = lexer.lex
    expect(tokens).to eq [
      [:TAG, "ul"],
      [:SELECTOR, ".list"],
      [:INDENT, 1],
      [:TAG, "li"],
      [:TAG, "li"],
      [:INDENT, 1],
      [:ATTRIBUTE, 'data-foo="bar baz"'],
      [:TAG, "span"],
      [:DEDENT, 2],
      [:TAG, "footer"],
      [:BLANK],
      [:INDENT, 1],
      [:MARKDOWN, "This is outdented content"]
    ]
  end

  it "can lex a tag with text content" do
    src = <<~SD
      /div = This is content
    SD
    lexer = Lexer.new(src)
    tokens = lexer.lex
    expect(tokens).to eq [
      [:TAG, "div"],
      [:TEXT, "This is content"]
    ]
  end
end
