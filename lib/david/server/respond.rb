require 'david/server/constants'
require 'david/server/mapping'
require 'david/server/utility'

module David
  class Server
    module Respond
      include CoAP::Coding

      include Constants
      include Mapping
      include Registry
      include Utility

      def respond(exchange, env = nil)
        block_enabled = @block && exchange.get?

        if block_enabled
          # Fail if m set.
          if exchange.block.more && !exchange.multicast?
            return error(exchange, 4.05)
          end
        end

        return error(exchange, 5.05) if exchange.proxy?

        env ||= basic_env(exchange)

        code, headers, body = @app.call(env)

        # No error responses on multicast exchanges.
        return if exchange.multicast? && !(200..299).include?(code)

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

        # No response on exchange for non-existent block.
        return if block_enabled && !exchange.block.included_by?(body)

        cf    = CoAP::Registry.convert_content_format(ct)
        etag  = etag_to_coap(headers, 4)
        loc   = location_to_coap(headers)
        ma    = max_age_to_coap(headers)
        mcode = code_to_coap(code)
        size  = headers[HTTP_CONTENT_LENGTH].to_i

        # App returned cf different from accept
        return error(exchange, 4.06) if exchange.accept && exchange.accept != cf

        response = initialize_response(exchange, mcode)

        response.options[:content_format] = cf
        response.options[:etag] = etag
        response.options[:location_path] = loc unless loc.nil?
        response.options[:max_age] = ma.to_i unless ma.nil?

        if @observe && handle_observe(exchange, env, etag)
          response.options[:observe] = 0
        end

        if block_enabled
          block = exchange.block.dup
          block.set_more!(body)

          response.payload = block.chunk(body)
          response.options[:block2] = block.encode
#         response.options[:size2]  = size if size != 0
        else
          response.payload = body
        end

        [response, {}]
      end

      private

      def basic_env(exchange)
        m = exchange.message

        {
          REMOTE_ADDR       => exchange.host,
          REMOTE_PORT       => exchange.port.to_s,
          REQUEST_METHOD    => method_to_http(m.mcode),
          SCRIPT_NAME       => EMPTY_STRING,
          PATH_INFO         => path_encode(m.options[:uri_path]),
          QUERY_STRING      => query_encode(m.options[:uri_query])
                                 .gsub(/^\?/, ''),
          SERVER_NAME       => @host,
          SERVER_PORT       => @port.to_s,
          CONTENT_LENGTH    => m.payload.bytesize.to_s,
          CONTENT_TYPE      => EMPTY_STRING,
          HTTP_ACCEPT       => accept_to_http(exchange),
          RACK_VERSION      => [1, 2],
          RACK_URL_SCHEME   => RACK_URL_SCHEME_HTTP,
          RACK_INPUT        => StringIO.new(m.payload),
          RACK_ERRORS       => $stderr,
          RACK_MULTITHREAD  => true,
          RACK_MULTIPROCESS => true,
          RACK_RUN_ONCE     => false,
          RACK_LOGGER       => @logger,
          COAP_VERSION      => 1,
          COAP_MULTICAST    => exchange.multicast?,
          COAP_DTLS         => COAP_DTLS_NOSEC,
          COAP_DTLS_ID      => EMPTY_STRING,
        }
      end

      def error(exchange, mcode)
        [initialize_response(exchange, mcode), retransmit: false]
      end

      def handle_observe(exchange, env, etag)
        return unless exchange.get? && exchange.observe?

        if exchange.message.options[:observe] == 0
          observe.add(exchange, env, etag)
          true
        else
          observe.delete(exchange)
          false
        end
      end

      def initialize_response(exchange, mcode = 2.05)
        type = exchange.con? ? :ack : :non

        CoAP::Message.new \
          tt: type,
          mcode: mcode,
          mid: exchange.message.mid || SecureRandom.random_number(0xffff),
          token: exchange.token
      end
    end
  end
end
