require_relative "node"

class Parser
  def initialize(tokens)
    @tokens = tokens
    @cursor = 0
  end

  def ast
    @ast ||= parse
  end

  def parse
    @ast = []

    while remaining?
      token = consume_next

      case token.type
      when :TAG
        @ast << parse_tag(token)
      when :MARKDOWN
        @ast << parse_markdown(token)
      when :BLANK
        # Do nothing when blank at top level!
      end
    end

    @ast
  end

  private

  def parse_tag start_tag
    tag = TagNode.new(start_tag.value)

    while remaining? && lookahead && lookahead.indentation > start_tag.indentation

      token = consume_next

      case token.type
      when :ATTRIBUTE
        tag.attributes << token.value
      when :SELECTOR
        tag.add_selector(token.value)
      when :TAG
        tag.add_child(parse_tag(token))
      when :MARKDOWN
        tag.add_child(parse_markdown(token))
      when :TEXT
        text = Node.new(:TEXT, token.value)
        tag.add_child(text)
      end
    end

    tag
  end

  def parse_markdown md_token
    markdown = Node.new(:MARKDOWN, md_token.value)

    while remaining? && lookahead.type != :TAG
      token = consume_next

      case token.type
      when :BLANK
        markdown.content += "\n\n"
      when :MARKDOWN
        markdown.content += "\n" + token.value
      else
        throw "Unexpected token in Markdown block"
      end
    end

    markdown
  end

  # Indexing

  def remaining?
    @cursor < @tokens.length
  end

  def lookahead(steps = 1)
    @tokens[@cursor + steps]
  end

  def lookbehind(steps = 1)
    @tokens[@cursor - steps]
  end

  def consume_next
    token = @tokens[@cursor]
    @cursor += 1

    token
  end
end
