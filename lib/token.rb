class TokenFactory
  def create(type, src, indent_level)
    case type
    when :TAG
      TagToken.new(src, indent_level)
    when :MARKDOWN
      MarkdownToken.new(src, indent_level)
    end
  end
end

class Token
  attr_reader :type, :src, :indent_level

  def initialize(type, src, indent_level)
    @type = type
    @src = src
    @indent_level = indent_level
  end

  def value
    raise "Not implemented"
  end

  def <=>(other)
    @indent_level <=> other.indent_level
  end

  def == other
    @type == other.type &&
      @src == other.src &&
      @indent_level == other.indent_level
  end
end

class TagToken < Token
  def initialize(src, indent_level)
    super(:TAG, src, indent_level)
  end

  def value
    @src
  end
end

class MarkdownToken < Token
  def initialize(src, indent_level)
    super(:MARKDOWN, src, indent_level)
  end

  def value
    @src
  end
end
