module David
  module Railties
    class Config < Rails::Railtie
      config.coap = ActiveSupport::OrderedOptions.new

      # Blockwise transfer
      config.coap.block = true

      # Transparent JSON<>CBOR conversion
      config.coap.cbor = false

      # Default Content-Type if HTTP_ACCEPT is empty
      config.coap.default_format = nil

      # Multicast
      config.coap.multicast = true

      # Observe
      config.coap.observe = true

      # david as default Rack handler (`rails s` starts david)
      config.coap.only = true

      # Resource Discovery
      config.coap.resource_discovery = true
    end
  end
end
