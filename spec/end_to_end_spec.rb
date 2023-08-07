require_relative "spec_helper"
require "nokogiri"

RSpec.describe Slashdown do
  let(:src) { File.read("spec/fixtures/example.sd") }
  let(:expected_html) { File.read("spec/fixtures/expected.html") }

  it "converts slashdown to html" do
    lexer = Slashdown::Lexer.new(src)
    tokens = lexer.tokens
    expect(tokens.length).to eq(35)

    parser = Slashdown::Parser.new(tokens)
    ast = parser.ast
    expect(ast.length).to eq(1)

    renderer = Slashdown::Renderer.new(ast)
    html = renderer.render

    # Parse the HTML fragments using Nokogiri
    parsed_html = Nokogiri::HTML::DocumentFragment.parse(html).canonicalize
    parsed_expected_html = Nokogiri::HTML::DocumentFragment.parse(expected_html).canonicalize

    expect(parsed_html.to_s).to eq(parsed_expected_html.to_s)

    # Write HTML to a file for manual checking
    File.write("output.html", html)
  end
end
