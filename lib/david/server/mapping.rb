module David
  class Server
    module Mapping
      protected

      def body_to_cbor(cbor, body, ct)
        if cbor && ct == 'application/json'
          body = JSON.parse(body).to_cbor
          ct = 'application/cbor'
        end

        [body, ct]
      end

      def coap_to_http_method(method)
        method.to_s.upcase
      end

      def etag(options, bytes = 8)
        etag = options['ETag']
        etag.delete('"').bytes.first(bytes * 2).pack('C*').hex if etag
      end

      def http_to_coap_code(code)
        code = code.to_i

        h = {200 => 205}
        code = h[code] if h[code]

        a = code / 100
        b = code - (a * 100)

        [a, b]
      end
    end
  end
end
