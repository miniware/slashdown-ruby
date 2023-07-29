class Parser
  def initialize(tokens)
    @tokens = tokens
    @line_num = 1
  end

  def parse
    parse_block
  end

  def errors
    @errors
  end

  private

  def parse_block(indent=0)
    nodes = []

    @tokens.each do |token|
      case token.type
      when :TAG
        # New tag
        tag, attrs_str = token.value.match(/^\/(\S+) (.*)/).captures
        attrs = attrs_str.scan(/(\S+)="([^"]+)"/).to_h rescue nil
        if attrs.nil?
          @errors << "Invalid attributes on line #{@line_num}"
          next
        end

        children = parse_block(indent + 2)
        nodes << Node.new(tag, children, attrs)

      when :EXPR
        # Expression
        exp = token.value[1..-1]
        nodes << Node.new("=", [exp])

      when :INLINE_EXPR
        # Inline expression
        exp = token.value
        nodes << exp

      when :HEADING
        # Heading
        level = token.value.count('#')
        text = token.value.split(' ', 2)[1]
        nodes << Node.new("h#{level}", [text])

      when :TEXT
        if indent > 0
          # Plain text
          nodes << token.value
        end

      else
        raise ParserError.new(@line_num, "Unhandled token type #{token.type}")
      end

      @line_num += 1
    end

    nodes
  end
end

class ParserError < StandardError
  attr_reader :line_num, :message

  def initialize(line_num, message)
    @line_num = line_num
    @message = message
  end
end