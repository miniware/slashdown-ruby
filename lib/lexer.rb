require_relative "token"

class Lexer
  attr_reader :indent_size

  def initialize(src, indent_size = 2)
    @src = src
    @indent_size = indent_size
    @tokens = []

    # Patterns to match
    # Each of these will be tried in order until one matches
    # Anything that falls through will be treated as markdown
    # Each pattern has a capture group which will be used as the value
    @patterns = [
      [:TAG, /\/([\w-]*)/],
      [:SELECTOR, /([.#][\w-]+)/],
      [:ATTRIBUTE, /([\w-]+="[^"]*")/],
      [:TEXT, /=\s+(.+)$/]
    ]
  end

  def tokens
    lex unless @tokens.length
    @tokens
  end

  def lex
    @src.each_line do |line|
      process_line(line)
    end

    @tokens
  end

  private

  def process_line(line)
    return if comment_line?(line)

    if blank_line?(line)
      handle_blank_line
    else
      handle_non_blank_line(line)
    end
  end

  def comment_line?(line)
    line.start_with?(/\A\s*\/\//)
  end

  def blank_line?(line)
    line.strip.empty?
  end

  def handle_blank_line
    @tokens << Token.new(:BLANK, nil, nil)
  end

  def handle_non_blank_line(line)
    indentation = calculate_indentation(line)
    line = line.strip

    if line.start_with?("/")
      process_tag_contents(line, indentation)
    elsif is_attribute?(line)
      @tokens << Token.new(:ATTRIBUTE, line, indentation)
    else
      @tokens << Token.new(:MARKDOWN, line, indentation)
    end
  end

  def is_attribute? line
    pattern = @patterns.find { |type, _| type == :ATTRIBUTE }.last
    pattern.match?( line )
  end

  def calculate_indentation(line)
    leading_spaces = line.match(/^\s*/)[0].length
    leading_spaces / @indent_size
  end

  def process_tag_contents(line, indentation)
    remainder = line.dup # copy so that we can use it as a fuse

    while remainder.length > 0
      @patterns.each do |type, pattern|
        match = remainder.match(pattern)
        next unless match

        footprint = match[0]
        value = match[1]

        # handle the shorthand `/`
        # TODO: move this to the parser
        value = "div" if type == :TAG && value == ""

        @tokens << Token.new(type, value, indentation)

        # burn down our fuse
        remainder = remainder[footprint.length..].strip
        break
      end
    end
  end

  def previous_token_type(index = 1)
    @tokens[-index]&.type if @tokens.any?
  end
end
