require 'david/server/mapping'
require 'david/server/utility'

module David
  class Server
    module Response
      include Mapping
      include Utility

      # Freeze some WSGI env keys.
      REMOTE_ADDR     = 'REMOTE_ADDR'.freeze
      REMOTE_PORT     = 'REMOTE_PORT'.freeze
      REQUEST_METHOD  = 'REQUEST_METHOD'.freeze
      SCRIPT_NAME     = 'SCRIPT_NAME'.freeze
      PATH_INFO       = 'PATH_INFO'.freeze
      QUERY_STRING    = 'QUERY_STRING'.freeze
      SERVER_NAME     = 'SERVER_NAME'.freeze
      SERVER_PORT     = 'SERVER_PORT'.freeze
      CONTENT_LENGTH  = 'CONTENT_LENGTH'.freeze
      CONTENT_TYPE    = 'CONTENT_TYPE'.freeze
      HTTP_ACCEPT     = 'HTTP_ACCEPT'.freeze

      # Freeze some Rack env keys.
      RACK_VERSION      = 'rack.version'.freeze
      RACK_URL_SCHEME   = 'rack.url_scheme'.freeze
      RACK_INPUT        = 'rack.input'.freeze
      RACK_ERRORS       = 'rack.errors'.freeze
      RACK_MULTITHREAD  = 'rack.multithread'.freeze
      RACK_MULTIPROCESS = 'rack.multiprocess'.freeze
      RACK_RUN_ONCE     = 'rack.run_once'.freeze
      RACK_LOGGER       = 'rack.logger'.freeze

      # Freeze some Rack env values.
      EMPTY_STRING          = ''.freeze
      CONTENT_TYPE_JSON     = 'application/json'.freeze
      CONTENT_TYPE_CBOR     = 'application/cbor'.freeze
      RACK_URL_SCHEME_HTTP  = 'http'.freeze

      protected

      def respond(host, port, request)
        block_enabled = request.mcode == :get ? @block : false

        if block_enabled
          block = if request.options[:block2].nil?
            CoAP::Block.new(0, false, 1024)
          else
            CoAP::Block.new(request.options[:block2]).decode
          end

          logger.debug block.inspect

          # Fail if m set.
          if block.more
            response = initialize_response(request)
            response.mcode = [4, 5]
            return [response, retransmit: false]
          end
        end

        env = basic_env(host, port, request)
        logger.debug env

        code, options, body = @app.call(env)

        ct = content_type(options)
        body = body_to_string(body)

        body.close if body.respond_to?(:close)

        if @cbor
          body = body_to_cbor(body)
          ct = CONTENT_TYPE_CBOR
        end

        return if block_enabled && !block.included_by?(body)

        mcode = http_to_coap_code(code)
        etag  = etag(options, 4)
        cf    = CoAP::Registry.convert_content_format(ct)

        response = initialize_response(request, mcode)

        if block_enabled
          block.more = block.more?(body)

          response.payload = block.chunk(body)
          response.options[:block2] = block.encode

          logger.debug block.inspect
        else
          response.payload = body
        end

        response.options[:etag] = etag
        response.options[:content_format] = cf

        [response, {}]
      end

      def basic_env(host, port, request)
        {
          REMOTE_ADDR       => host,
          REMOTE_PORT       => port.to_s,
          REQUEST_METHOD    => coap_to_http_method(request.mcode),
          SCRIPT_NAME       => EMPTY_STRING,
          PATH_INFO         => path_encode(request.options[:uri_path]),
          QUERY_STRING      => query_encode(request.options[:uri_query])
                                  .gsub(/^\?/, ''),
          SERVER_NAME       => @host,
          SERVER_PORT       => @port.to_s,
          CONTENT_LENGTH    => request.payload.size.to_s,
          CONTENT_TYPE      => CONTENT_TYPE_JSON,
          HTTP_ACCEPT       => CONTENT_TYPE_JSON,
          RACK_VERSION      => [1, 2],
          RACK_URL_SCHEME   => RACK_URL_SCHEME_HTTP,
          RACK_INPUT        => StringIO.new(request.payload),
          RACK_ERRORS       => $stderr,
          RACK_MULTITHREAD  => true,
          RACK_MULTIPROCESS => true,
          RACK_RUN_ONCE     => false,
          RACK_LOGGER       => @logger,
        }
      end

      def initialize_response(request, mcode = 2.00)
        type = request.tt == :con ? :ack : :non

        CoAP::Message.new \
          tt: type,
          mcode: mcode,
          mid: request.mid,
          token: request.options[:token]
      end
    end
  end
end
