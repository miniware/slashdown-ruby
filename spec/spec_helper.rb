require "simplecov"
SimpleCov.start

require "rspec"
RSpec.configure do |config|
  config.formatter = :progress

  config.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end
end

require "awesome_print"

require_relative "../lib/lexer"
require_relative "../lib/parser"
require_relative "../lib/renderer"
require_relative "../lib/token"
require_relative "../lib/node"
