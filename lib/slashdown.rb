require_relative "lexer"
require_relative "parser"
require_relative "renderer"

module Slashdown
  class TemplateRenderer
    def self.render(src, context)
      # Replace variables in the src
      context.each do |key, value|
        src.gsub!("{{#{key}}}", value.to_s)
      end

      # Parse the template
      lexer = Lexer.new(src)
      tokens = lexer.tokens
      parser = Parser.new(tokens)
      ast = parser.ast

      # Render the AST to HTML
      renderer = Renderer.new(ast)
      renderer.render
    end
  end
end
