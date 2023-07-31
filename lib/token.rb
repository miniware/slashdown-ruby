class Token
  include Comparable
  attr_reader :type, :value, :indentation

  def initialize(type, value, indentation = 0)
    @type = type
    @value = value
    @indentation = indentation
  end

  def <=>(other)
    self.indentation <=> other.indentation
  end

  def ==(other)
    self.type == other.type &&
    self.value == other.value &&
    self.indentation == other.indentation
  end
end
