module Slashdown
  class Token
    attr_reader :type, :value, :indentation

    def initialize(type, value, indentation = 0)
      @type = type
      @value = value
      @indentation = indentation
    end

    def ==(other)
      type == other.type &&
        value == other.value &&
        indentation == other.indentation
    end
  end
end
