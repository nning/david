module David
  class Server
    module Mapping
      include Constants

      protected

      def body_to_cbor(body)
        JSON.parse(body).to_cbor
      end

      def coap_to_http_method(method)
        method.to_s.upcase
      end

      def etag_to_coap(options, bytes = 8)
        etag = options[HTTP_ETAG]
        etag.delete('"').bytes.first(bytes * 2).pack('C*').hex if etag
      end

      def http_to_coap_code(code)
        code = code.to_i

        h = {200 => 205, 304 => 203}
        code = h[code] if h[code]

        a = code / 100
        b = code - (a * 100)

        [a, b]
      end

      def max_age(options)
        options[HTTP_CACHE_CONTROL][/max-age=([0-9]*)/, 1]
      rescue NoMethodError
        nil
      end
    end
  end
end
