require "spec_helper"
require "lexer"

RSpec.describe Lexer do
  it "can lex a simple tag" do
    lexer = Lexer.new("/div")
    tokens = lexer.lex
    expect(tokens).to eq [
      [:TAG, "/div"]
    ]
  end

  it "can lex a blank tag with a class" do
    lexer = Lexer.new("/ .my-class")
    tokens = lexer.lex
    expect(tokens).to eq [
      [:TAG, "/"],
      [:SELECTOR, ".my-class"]
    ]
  end

  it "can lex multiple selectors" do
    lexer = Lexer.new("/section #hero.grid")
    tokens = lexer.lex
    expect(tokens).to eq [
      [:TAG, "/section"],
      [:SELECTOR, "#hero"],
      [:SELECTOR, ".grid"]
    ]
  end

  it "can lex a tag with an attribute" do
    lexer = Lexer.new('/div data-foo="bar baz"')
    tokens = lexer.lex
    expect(tokens).to eq [
      [:TAG, "/div"],
      [:ATTRIBUTE, 'data-foo="bar baz"']
    ]
  end

  it "can lex a simple tag with a class and an attribute" do
    lexer = Lexer.new('/div .my-class data-foo="bar baz"')
    tokens = lexer.lex
    expect(tokens).to eq [
      [:TAG, "/div"],
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
      [:TAG, "/div"],
      [:INDENT, nil],
      [:ATTRIBUTE, 'data-foo="bar baz"'],
      [:INDENT, nil],
      [:CONTENT, "This is content"]
    ]
  end

  it "tracks indentation properly" do
    src = <<~SD
      /ul .list

        This is content

      // This is a comment which should be ignored
        /li

          This is more content

        /li

          This is even more content

      /footer

        This is outdented content
    SD

    lexer = Lexer.new(src)
    tokens = lexer.lex
    expect(tokens).to eq [
      [:TAG, "/ul"],
      [:SELECTOR, ".list"],

      [:INDENT, nil],
      [:CONTENT, "This is content"],

      [:TAG, "/li"],
      [:INDENT, nil],
      [:CONTENT, "This is more content"],

      [:DEDENT, nil],
      [:TAG, "/li"],
      [:INDENT, nil],
      [:CONTENT, "This is even more content"],

      [:DEDENT, nil],
      [:DEDENT, nil],
      [:TAG, "/footer"],
      [:INDENT, nil],
      [:CONTENT, "This is outdented content"],
    ]
  end
end
