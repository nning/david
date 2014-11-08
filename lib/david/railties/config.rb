module David
  module Railties
    class Config < Rails::Railtie
      config.coap = ActiveSupport::OrderedOptions.new

      # Blockwise transfer
      config.coap.block     = true

      # Transparent JSON<>CBOR conversion
      config.coap.cbor      = true

      # Multicast
      config.coap.multicast = true

      # Observe
      config.coap.observe   = true

      # david as default Rack handler (`rails s` starts david)
      config.coap.only      = true
    end
  end
end
