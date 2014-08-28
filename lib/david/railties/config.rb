module David
  module Railties
    class Config < Rails::Railtie
      config.coap = ActiveSupport::OrderedOptions.new
      config.coap.cbor = true
      config.coap.only = true
    end
  end
end
