# Monkey-patch Rack to accept Float status codes.
# https://github.com/rack/rack/blob/master/lib/rack/utils.rb#L647
module Rack
  module Utils
    def status_code(status)
      case status
      when Symbol
        SYMBOL_TO_STATUS_CODE[status] || 500
      when Float
        status
      else
        status.to_i
      end
    end

    module_function :status_code
  end
end
