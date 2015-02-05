class Trap
  def initialize(value)
    @value = value
  end

  def method_missing(method, *args)
    p method, caller[0]
    @value.send(method, *args)
  end
end
