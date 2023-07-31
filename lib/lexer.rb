class Lexer
  def initialize(src, indent_size = 2)
    @src = src
    @indent_size = indent_size
  end

  def lex
    @tokens = []
    @current_indentation = 0

    # Patterns to match
    # Each of these will be tried in order until one matches
    # Anything that falls through will be treated as markdown
    # Each pattern has a capture group which will be used as the value
    patterns = [
      [:TAG, /\/([\w-]*)/],
      [:SELECTOR, /([.#][\w-]+)/],
      [:ATTRIBUTE, /([\w-]+="[^"]*")/],
      [:TEXT, /=\s+(.+)$/]
    ]

    blank_since_last_tag = false

    @src.each_line do |line|
      # skip comments
      next if line.start_with?(/\A\s*\/\//)

      # Blank lines are important but shouldn't affect indentation
      if line.strip.empty?
        @tokens << [:BLANK]
        blank_since_last_tag = true
        next
      end

      # Track indentation
      track_indent(line)
      line = line.strip

      # Start a tag
      if line.start_with?("/")
        blank_since_last_tag = false

        # look for patterns until we've consumed the whole line
        # (selectors, attributes, etc.)
        remainder = line.dup # we'll be chomping into this
        while remainder.length > 0
          patterns.each do |type, pattern|
            match = remainder.match(pattern)

            if match
              footprint = match[0] # the whole match
              value = match[1]     # the capture group

              @tokens << [type, value]

              remainder = remainder[footprint.length..].strip
              break
            end
          end
        end

      # Attributes immediately following tags on new lines
      elsif previous_token_type == :INDENT &&
          !blank_since_last_tag &&
          patterns.find { |type, _| type == :ATTRIBUTE }.last.match?(line)

        @tokens << [:ATTRIBUTE, line]

      # TODO: handle multiline code blocks
      else # Markdown
        @tokens << [:MARKDOWN, line]
      end
    end

    @tokens
  end

  private

  def previous_token_type index = 1
    @tokens[-index]&.first if @tokens.any?
  end

  def track_indent(line)
    spaces = line.match(/^\s*/)[0].length
    indentation = spaces / @indent_size

    is_child = indentation > @current_indentation
    is_elder = indentation < @current_indentation

    if is_child
      @tokens << [:INDENT, 1]
    elsif is_elder
      dedents = @current_indentation - indentation
      @tokens << [:DEDENT, dedents]
    end

    @current_indentation = indentation

    spaces
  end
end

if __FILE__ == $0
  src = <<~SD
    /ul .list

    // This is a comment which should be ignored
      /li
        data-foo="bar baz"
      /li

        This is even more content

    /footer

      This is outdented content
  SD

  lexer = Lexer.new(src)
  tokens = lexer.lex

  tokens.each do |type, value|
    puts type.to_s + (value ? "  #{value.inspect}" : "")
  end
end
