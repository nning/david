module Rack
  module Handler
    class CoAP < David
    end

    register :coap, CoAP
  end
end
