require "rspec"

RSpec.configure do |config|
  config.formatter = :progress
end

require_relative "../lib/lexer"
