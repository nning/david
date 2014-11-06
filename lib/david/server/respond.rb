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
          if request.block.more
            response = initialize_response(request, 4.05)
            return [response, retransmit: false]
          end
        end

        env ||= basic_env(request)

        code, options, body = @app.call(env)

        ct = options[HTTP_CONTENT_TYPE]
        body = body_to_string(body)

        body.close if body.respond_to?(:close)

        if @cbor
          body = body_to_cbor(body)
          ct = CONTENT_TYPE_CBOR
        end

        return if block_enabled && !request.block.included_by?(body)

        cf     = CoAP::Registry.convert_content_format(ct)
        etag   = etag(options, 4)
        mcode  = http_to_coap_code(code)

        ma = max_age(options)
        ma = ma.to_i unless ma.nil?

        response = initialize_response(request, mcode)

        handle_observe(request, response, env, etag) if @observe

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
          CONTENT_TYPE      => CONTENT_TYPE_JSON,
          HTTP_ACCEPT       => CONTENT_TYPE_JSON,
          RACK_VERSION      => [1, 2],
          RACK_URL_SCHEME   => RACK_URL_SCHEME_HTTP,
          RACK_INPUT        => StringIO.new(m.payload),
          RACK_ERRORS       => $stderr,
          RACK_MULTITHREAD  => true,
          RACK_MULTIPROCESS => true,
          RACK_RUN_ONCE     => false,
          RACK_LOGGER       => @logger,
          COAP_VERSION      => 1,
        }
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
