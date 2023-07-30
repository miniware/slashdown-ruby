class Lexer
  def initialize(src, indent_size = 2)
    @src = src
    @indent_size = indent_size
  end

  def lex
    @tokens = []
    @current_indentation = 0

    patterns = [
      [:TAG, /\/[\w-]*/],
      [:SELECTOR, /[.#][\w-]+/],
      [:ATTRIBUTE, /[\w-]+="[^"]*"/]
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

      # Tags
      if line.start_with?("/")
        remainder = line.dup
        blank_since_last_tag = false

        while remainder.length > 0
          patterns.each do |type, pattern|
            match = remainder.match(pattern)

            if match
              value = match[0]
              @tokens << [type, value]

              remainder = remainder[value.length..].strip
              break
            end
          end
        end

      # Followup Attributes
      elsif previous_token_type == :INDENT && !blank_since_last_tag
        *_, pattern = patterns.find { |type, _| type == :ATTRIBUTE }

        if pattern.match?(line)
          @tokens << [:ATTRIBUTE, line]
        end

      # Parse as Markdown if we've seen a blank line since the last tag
      elsif blank_since_last_tag
        @tokens << [:MARKDOWN, line]

      else
        raise "Unmatched line: #{line}"
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
