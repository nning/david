module David
  module Actor
    def self.included(base)
      base.send(:include, Celluloid)
      base.send(:include, Registry)
    end
  end
end
