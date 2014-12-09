require 'david/server/constants'
require 'david/server/mapping'
require 'david/server/utility'

module David
  class Server
    module Respond
      include Constants
      include Mapping
      include Utility

      def respond(request, env = nil)
        block_enabled = @block && request.get?

        if block_enabled
          # Fail if m set.
          if request.block.more && !request.multicast?
            return error(request, 4.05)
          end
        end

        env ||= basic_env(request)

        code, headers, body = @app.call(env)

        # No error responses on multicast requests.
        return if request.multicast? && !(200..299).include?(code)

        ct = headers[HTTP_CONTENT_TYPE]
        body = body_to_string(body)

        body.close if body.respond_to?(:close)

        if @cbor && ct == 'application/json'
          begin
            body = body_to_cbor(body)
            ct = CONTENT_TYPE_CBOR
          rescue JSON::ParserError
          end
        end

        # No response on request for non-existent block.
        return if block_enabled && !request.block.included_by?(body)

        cf    = CoAP::Registry.convert_content_format(ct)
        etag  = etag(headers, 4)
        mcode = http_to_coap_code(code)

        # App returned cf different from accept
        return error(request, 4.06) if request.accept && request.accept != cf

        ma = max_age(headers)
        ma = ma.to_i unless ma.nil?

        response = initialize_response(request, mcode)

        async.handle_observe(request, response, env, etag) if @observe

        if block_enabled
          block = request.block.dup
          block.set_more!(body)

          response.payload = block.chunk(body)
          response.options[:block2] = block.encode
        else
          response.payload = body
        end

        response.options[:content_format] = cf
        response.options[:etag] = etag
        response.options[:max_age] = ma unless ma.nil?

        [response, {}]
      end

      private

      def basic_env(request)
        m = request.message

        {
          REMOTE_ADDR       => request.host,
          REMOTE_PORT       => request.port.to_s,
          REQUEST_METHOD    => coap_to_http_method(m.mcode),
          SCRIPT_NAME       => EMPTY_STRING,
          PATH_INFO         => path_encode(m.options[:uri_path]),
          QUERY_STRING      => query_encode(m.options[:uri_query])
                                 .gsub(/^\?/, ''),
          SERVER_NAME       => @host,
          SERVER_PORT       => @port.to_s,
          CONTENT_LENGTH    => m.payload.bytesize.to_s,
          CONTENT_TYPE      => EMPTY_STRING,
          HTTP_ACCEPT       => http_accept(request),
          RACK_VERSION      => [1, 2],
          RACK_URL_SCHEME   => RACK_URL_SCHEME_HTTP,
          RACK_INPUT        => StringIO.new(m.payload),
          RACK_ERRORS       => $stderr,
          RACK_MULTITHREAD  => true,
          RACK_MULTIPROCESS => true,
          RACK_RUN_ONCE     => false,
          RACK_LOGGER       => @logger,
          COAP_VERSION      => 1,
          COAP_MULTICAST    => request.multicast?,
        }
      end

      def error(request, mcode)
        [initialize_response(request, mcode), retransmit: false]
      end

      def handle_observe(request, response, env, etag)
        return unless request.get? && request.observe?

        if request.message.options[:observe] == 0
          observe.add(request, env, etag)
          response.options[:observe] = 0
        else
          observe.delete(request)
        end
      end

      def http_accept(request)
        CoAP::Registry.convert_content_format(request.accept) ||
          CONTENT_TYPE_JSON
      end

      def initialize_response(request, mcode = 2.00)
        type = request.con? ? :ack : :non

        CoAP::Message.new \
          tt: type,
          mcode: mcode,
          mid: request.message.mid || SecureRandom.random_number(0xffff),
          token: request.token
      end

      def observe
        Celluloid::Actor[:observe]
      end
    end
  end
end
