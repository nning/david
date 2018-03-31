module David
  module Railties
    class Config < Rails::Railtie
      config.coap = ActiveSupport::OrderedOptions.new

      # Blockwise transfer
      config.coap.block = nil

      # Transparent JSON<>CBOR conversion
      config.coap.cbor = nil

      # Default Content-Type if HTTP_ACCEPT is empty
      config.coap.default_format = nil

      # Multicast
      config.coap.multicast = nil

      # Multicast group configuration
      config.coap.multicast_groups = nil

      # Observe
      config.coap.observe = nil

      # david as default Rack handler (`rails s` starts david)
      config.coap.only = true

      # Resource Discovery
      config.coap.resource_discovery = true
    end
  end
end
