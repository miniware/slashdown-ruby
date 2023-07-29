# require everything in lib
Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }
require 'listen'

throw 'Usage: ruby watch.rb <path>' unless ARGV[0]

watch_path = ARGV[0]
puts "Watching for changes to #{watch_path}..."

Listen.to(watch_path) do |modified, added, removed|
  modified.each do |path|
    next unless path.end_with?('.sd')

    lexer = Lexer.new(File.read(path))
    tokens = lexer.lex

    puts tokens.inspect

    puts "#{path} changed..."
  end
end.start
sleep