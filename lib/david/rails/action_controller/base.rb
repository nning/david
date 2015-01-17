class ActionController::Base
  def self.discoverable(options)
    discovery_actor.register(self, options)
  end

  protected

  def self.discovery_actor
    Celluloid::Actor[:discovery]
  end
end
