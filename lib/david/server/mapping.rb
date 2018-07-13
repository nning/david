module David
  class Server
    module Mapping
      include Constants

      HTTP_TO_COAP_CODES = {
        200 => 205,
        202 => 201,
        203 => 205,
        204 => 205,
        304 => 203,
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

      HTTP_TO_COAP_CODES_MINIMAL = {
        200 => 205,
      }.freeze

      protected
    
      def accept_to_http(request)
        if request.accept.nil?
          @options[:DefaultFormat]
        else
          ::CoAP::Registry.convert_content_format(request.accept)
        end
      end

      def body_to_cbor(json)
        JSON.parse(json).to_cbor
      end

      def body_to_json(cbor)
        if cbor.is_a?(String)
          CBOR.load(cbor).to_json
        else
          cbor.to_json
        end
      end

      def code_to_coap(code)
        set_http_to_coap_codes!

        return float_to_array(code) if code.is_a?(Float)

        code = code.to_i
        code = @http_to_coap_codes[code] if @http_to_coap_codes[code]

        int_to_array(code)
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

      def float_to_array(float)
        [float.to_i, (float * 100 % 100).round]
      end

      def int_to_array(int)
        int = int.to_i

        a = int / 100
        b = int - (a * 100)

        [a, b]
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

      def media_type_strip(media_type)
        return nil if media_type.nil?
        media_type.split(';')[0]
      end

      def method_to_http(method)
        method.to_s.upcase
      end

      def set_http_to_coap_codes!
        @http_to_coap_codes ||= begin
          if @options && @options[:MinimalMapping]
            HTTP_TO_COAP_CODES_MINIMAL
          else
            HTTP_TO_COAP_CODES
          end
        end
      end
    end
  end
end
