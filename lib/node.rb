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
end

class TagNode < Node
  attr_accessor :attributes, :ids, :classes

  def initialize identifier
    super(:TAG, identifier)

    @attributes = []
    @ids = []
    @classes = []
  end

  def identifier
    self.content
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
end
