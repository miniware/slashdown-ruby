require_relative "node"

module Slashdown
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

      while remaining_tokens?
        token = consume_next

        case token.type
        when :TAG
          @ast << parse_tag(token)
        when :MARKDOWN
          @ast << parse_markdown(token)
        end
      end

      @ast
    end

    private

    # A tag likely has many children, recurses
    def parse_tag start_tag
      identifier = start_tag.value
      identifier = "div" if identifier.empty? # handle `/` shorthand
      tag = TagNode.new(identifier)

      while remaining_tokens?
        next_token = lookahead

        if next_token.type == :BLANK
          # :BLANKs are only important within :MARKDOWN
          # So we eat the next token and move on
          consume_next
          next
        end

        indentation_immune_tokens = [:ATTRIBUTE, :SELECTOR, :TEXT]

        if next_token.indentation > start_tag.indentation || indentation_immune_tokens.include?(next_token.type)
          token = consume_next

          case token.type
          when :MARKDOWN
            tag.add_child(parse_markdown(token)) if next_token.indentation > start_tag.indentation

          when :TAG
            tag.add_child(parse_tag(token)) if next_token.indentation > start_tag.indentation

          when :ATTRIBUTE
            tag.add_attribute token.value

          when :SELECTOR
            tag.add_selector token.value

          when :TEXT
            tag.add_child Node.new(:TEXT, token.value)

          end
        else
          break # exit the loop
        end
      end

      tag
    end

    def parse_markdown md_token
      markdown = Node.new(:MARKDOWN, md_token.value)

      while remaining_tokens? && lookahead.type != :TAG
        token = consume_next

        case token.type
        when :BLANK
          markdown.content += "\n"
        when :MARKDOWN
          markdown.content += "\n" + token.value
        else
          throw "Unexpected token in Markdown block: #{token.inspect}"
        end
      end

      markdown
    end

    # Indexing

    def remaining_tokens?
      !lookahead.nil?
    end

    def lookahead
      return nil if @cursor >= @tokens.length

      # this *isn't* +1 because of zero-indexing
      @tokens[@cursor]
    end

    def lookbehind
      index = @cursor - 1
      return nil if index < 0

      @tokens[@cursor - 1]
    end

    def consume_next
      token = @tokens[@cursor]
      @cursor += 1

      token
    end
  end
end
