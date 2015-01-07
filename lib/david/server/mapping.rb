module David
  class Server
    module Mapping
      include Constants

      HTTP_TO_COAP_CODES = {
        200 => 205,
        202 => 201,
        203 => 205,
        204 => 205,
        407 => 401,
        408 => 400,
        409 => 412,
        410 => 404,
        411 => 402,
        414 => 402,
        505 => 500,
        506 => 500,
        511 => 500,
      }.freeze

      protected
    
      def accept_to_http(request)
        if request.accept.nil?
          @default_format
        else
          CoAP::Registry.convert_content_format(request.accept)
        end
      end

      def body_to_cbor(body)
        JSON.parse(body).to_cbor
      end

      def code_to_coap(code)
        code = code.to_i
        code = HTTP_TO_COAP_CODES[code] if HTTP_TO_COAP_CODES[code]

        a = code / 100
        b = code - (a * 100)

        [a, b]
      end

      def etag_to_coap(headers, bytes = 8)
        etag = headers[HTTP_ETAG]

        if etag
          etag = etag.split('"')
          etag = etag[1] || etag[0]

          etag
            .bytes
            .first(bytes * 2)
            .pack('C*')
            .hex
        end
      end

      def location_to_coap(headers)
        l = headers[HTTP_LOCATION].split('/').reject(&:empty?)
        return l.empty? ? nil : l
      rescue NoMethodError
        nil
      end

      def max_age_to_coap(headers)
        headers[HTTP_CACHE_CONTROL][/max-age=([0-9]*)/, 1]
      rescue NoMethodError
        nil
      end

      def method_to_http(method)
        method.to_s.upcase
      end
    end
  end
end
