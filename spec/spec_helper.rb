require "rspec"

RSpec.configure do |config|
  config.formatter = :progress

  config.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end
end

require_relative "../lib/lexer"
