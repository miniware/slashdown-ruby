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
    indentation = 0
    blank_since_last_tag = false

    @src.each_line do |line|
      next if line.start_with?(/\A\s*\/\//) # skip comments

      # Blank lines are important (for MD) but shouldn't affect indentation
      if line.strip.empty?
        @tokens << Token.new(:BLANK, nil, indentation)
        blank_since_last_tag = true
        next
      end

      indentation = calculate_indentation(line)
      line = line.strip

      # is it a tag?
      if line.start_with?("/")
        blank_since_last_tag = false
        process_tag_contents(line, indentation)

      # what about an attribute?
      elsif is_attribute?(line) && !blank_since_last_tag
        @tokens << Token.new(:ATTRIBUTE, line, indentation)

      # let's just call it markdown...
      else
        @tokens << Token.new(:MARKDOWN, line, indentation)
      end
    end

    @tokens
  end

  private

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
