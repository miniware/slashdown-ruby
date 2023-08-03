require_relative "token"

class Lexer
  attr_reader :indent_size

  def initialize(src, indent_size = 2)
    raise ArgumentError, "Source code cannot be nil" if src.nil?
    raise ArgumentError, "Source code must be a string" unless src.is_a?(String)

    @src = src
    @indent_size = indent_size
    @tokens = []

    # Patterns to match
    # THE ORDER IS VERY IMPORTANT
    # Anything that falls through will be treated as markdown
    # Each pattern has a capture group which will be used as the value
    @patterns = [
      [:TAG, /\/([\w-]*)/],
      [:SELECTOR, /([.#][\w-]+)/],
      [:TEXT, /=\s+(.+)$/],
      [:ATTRIBUTE, /([\w-]+="[^"]*")|([\w-]+)/]
    ]

    # this helps us track whether or not
    # there's been an empty line since the last tag
    @directly_under_last_tag = false
  end

  def tokens
    lex if @tokens.empty?
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
      @directly_under_last_tag = false
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

    # It's a tag!
    if line.start_with?("/")
      process_tag_contents(line, indentation)
      @directly_under_last_tag = true

    # or an attribute right after a tag!
    elsif @directly_under_last_tag && is_attribute?(line)
      @tokens << Token.new(:ATTRIBUTE, line, indentation)

    # otherwise it's Markdown's problem
    else
      @tokens << Token.new(:MARKDOWN, line, indentation)
    end
  end

  def is_attribute? line
    pattern = @patterns.find { |type, _| type == :ATTRIBUTE }.last
    pattern.match?(line)
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
        value = match.captures.compact.first

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
end
