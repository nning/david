module David
  class FakeLogger
    def initialize
      Celluloid.logger = nil
    end

    [:info, :debug, :warn, :error, :fatal].each do |method|
      define_method(method) { |*args| }
    end
  end
end
