class Lexer
  def initialize(src, indent_size = 2)
    @src = strip_comments(src)
    @indent_size = indent_size
  end

  def lex
    @tokens = []
    @current_indentation = 0

    # We split by double (or more) newlines (may have whitespace in between) to get the initial blocks
    blocks = @src.strip.split(/(\n\s*\n)+/)
    # TODO:
    # - handle tags that immediately follow each other
    # - handle markdown headings that immediately follow a tag
    # - Catching indentation and line numbers is a bit hacky

    blocks.each do |block|
      if block.match?(/^\s*$/) # It's a blank line
        @tokens << [:BLANK, nil]
        next
      end

      track_indent(block)

      block = block.strip # Strip leading / trailing whitespace
      if block.start_with?("/") # It's a tag
        # collapse any newlined attributes etc
        block = block.split("\n").map(&:strip).join(" ")

        # check if the last item is a markdown heading
        # if so, split it off and add it as a separate token
        blocks = block.split(" ")
        last_item = blocks[-1]
        if last_item.match?(/^\#{1,6}\s+.+/)
          # It's a markdown heading
          heading = blocks.pop
          @tokens << [:MARKDOWN, heading]
        end
        block = blocks.join(" ")

        @tokens << [:TAG, block]

      else # handoff to Markdown
        @tokens << [:MARKDOWN, block]
      end
    end

    @tokens
  end

  private

  def track_indent(line)
    indentation = line.match(/^ */)[0].length / @indent_size

    if indentation > @current_indentation
      @current_indentation = indentation
      @tokens << [:INDENT, nil]
    elsif indentation < @current_indentation
      (@current_indentation - indentation).times do
        @current_indentation -= 1
        @tokens << [:DEDENT, nil]
      end
    end
  end

  def strip_comments(src)
    src.gsub(/\/\/.*/, "")
  end
end
