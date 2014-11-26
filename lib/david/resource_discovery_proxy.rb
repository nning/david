require 'david/resource_discovery'

module David
  class ResourceDiscoveryProxy
    def initialize(app)
      ResourceDiscovery.supervise_as(:discovery, app)
    end

    def call(env)
      Celluloid::Actor[:discovery].call(env)
    end
  end
end
