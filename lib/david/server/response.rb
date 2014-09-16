require 'david/server/mapping'
require 'david/server/utility'

module David
  class Server
    module Response
      include Mapping
      include Utility

      protected

      def respond(host, port, request)
        env = basic_env(host, port, request)
        logger.debug env

        code, options, body = @app.call(env)

        ct = content_type(options)
        body = body_to_string(body)

        body.close if body.respond_to?(:close)

        if @cbor
          body = body_to_cbor(body)
          ct = 'application/cbor'
        end

        response = initialize_response(request)

        response.mcode = http_to_coap_code(code)
        response.payload = body

        response.options[:etag] = etag(options, 4)
        response.options[:content_format] = 
          CoAP::Registry.convert_content_format(ct)

        response
      end

      def basic_env(host, port, request)
        {
          'REMOTE_ADDR'       => host,
          'REMOTE_PORT'       => port.to_s,
          'REQUEST_METHOD'    => coap_to_http_method(request.mcode),
          'SCRIPT_NAME'       => '',
          'PATH_INFO'         => path_encode(request.options[:uri_path]),
          'QUERY_STRING'      => query_encode(request.options[:uri_query])
                                   .gsub(/^\?/, ''),
          'SERVER_NAME'       => @host,
          'SERVER_PORT'       => @port.to_s,
          'CONTENT_LENGTH'    => request.payload.size.to_s,
          'CONTENT_TYPE'      => 'application/json',
          'HTTP_ACCEPT'       => 'application/json',
          'rack.version'      => [1, 2],
          'rack.url_scheme'   => 'http',
          'rack.input'        => StringIO.new(request.payload),
          'rack.errors'       => $stderr,
          'rack.multithread'  => true,
          'rack.multiprocess' => true,
          'rack.run_once'     => false,
          'rack.logger'       => @logger,
        }
      end

      def initialize_response(request)
        CoAP::Message.new \
          tt: :ack,
          mcode: 2.00,
          mid: request.mid,
          token: request.options[:token]
      end
    end
  end
end
