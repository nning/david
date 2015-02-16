module David
  class Trap
    def initialize(value = nil)
      @value = value
    end

    def method_missing(method, *args)
      p method, caller[0]
      @value.send(method, *args) unless @value.nil?
    end
  end
end
