# require 'parser'
# require 'renderer'

# RSpec.describe 'End to end' do
#   skip "Skip!"

#   it 'parses and renders a sample doc' do
#     # Load sample input
#     sample_input = File.read('spec/fixtures/sample.sd')

#     # Parse to AST
#     lexer = Lexer.new(sample_input)
#     tokens = lexer.lex
#     parser = Parser.new(tokens)
#     ast = parser.parse

#     # Render HTML
#     renderer = HTMLRenderer.new
#     html = renderer.render(ast)

#     # Read and check expected HTML
#     expected_html = File.read('spec/fixtures/expected.html')
#     expect(html).to eq(expected_html)
#   end
# end