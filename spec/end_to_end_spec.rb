require_relative "spec_helper"

RSpec.describe "Slashdown compiler" do
  let(:src) { File.read("spec/fixtures/example.sd") }
  let(:expected_html) { File.read("spec/fixtures/expected.html") }

  it "converts slashdown to html" do
    lexer = Lexer.new(src)
    tokens = lexer.tokens

    # expect(tokens.length).to eq(36)

    # parser = Parser.new(tokens)
    # ast = parser.ast

    # expect(ast.length).to eq(1)

    # renderer = Renderer.new(ast)
    # html = renderer.render
    # expect(html).to eq(expected_html)

    # Write HTML to a file for manual checking
    # File.write("output.html", html)
  end
end
