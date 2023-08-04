class Node
  attr_reader :type, :children
  attr_accessor :content

  def initialize(type, content = nil)
    @type = type
    @content = content
    @children = []
  end

  def add_child node
    @children << node
  end

  def to_h
    {
      type: @type,
      content: @content,
      children: @children.map(&:to_h)
    }
  end

end

class TagNode < Node
  # TODO: Implement self closing tags

  def initialize identifier
    super(:TAG, identifier)

    @attributes = []
    @ids = []
    @classes = []
  end

  def identifier
    @content
  end

  def add_attribute attribute
    @attributes << attribute
  end

  def add_selector selector
    prefix, *rest = selector[0], selector[1..]
    rest = rest.join ""
    case prefix
    when "#"
      @ids << rest
    when "."
      @classes << rest
    else
      raise "Unexpected character in selector"
    end
  end

  def all_attributes
    classes = "class=\"#{@classes.join(" ")}\"" unless @classes.empty?
    ids = "id=\"#{@ids.join(" ")}\"" unless @ids.empty?

    [ids, classes].compact.concat @attributes
  end

  def to_h
    {
      type: @type,
      identifier: identifier,
      attributes: all_attributes,
      children: @children.map(&:to_h)
    }
  end

end
