module David
  class Server
    include Celluloid::IO
    include CoAP::Codification

    attr_reader :logger

    finalizer :shutdown

    def initialize(app, options)
      @host   = options[:Host]
      @port   = options[:Port].to_i
      @cbor   = !!options[:CBOR]

      @logger = setup_logger(!!options[:Debug])

      @app    = app.respond_to?(:new) ? app.new : app

      if options[:CBOR].nil? && defined? Rails
        @cbor = Rails.application.config.coap.cbor
      end

      logger.info "David #{David::VERSION} on #{RUBY_DESCRIPTION}"
      logger.info "Starting on [#{@host}]:#{@port}"

      ipv6 = IPAddr.new(@host).ipv6?
      af = ipv6 ? ::Socket::AF_INET6 : ::Socket::AF_INET

      # Actually Celluloid::IO::UDPServer.
      # (Use celluloid-io from git, 0.15.0 does not support AF_INET6).
      @socket = UDPSocket.new(af)
      @socket.bind(@host, @port)

      async.run
    end

    private

    def shutdown
      @socket.close unless @socket.nil?
    end

    def run
      loop { async.handle_input(*@socket.recvfrom(1024)) }
    end

    def answer(host, port, message)
      @socket.send(message.to_wire, 0, host, port)
    end

    def app_response(host, port, request)
      env = basic_env(host, port, request)
      logger.debug env

      code, options, body = @app.call(env)

      ct = options['Content-Type']
      ct = ct.split(';').first unless ct.nil?

      new_body = ''
      body.each do |line|
        new_body += line + "\r\n"
      end
      new_body.chomp!

      if @cbor && ct == 'application/json'
        new_body = JSON.parse(new_body).to_cbor
        ct = 'application/cbor'
      end

      response = initialize_response(request)
      response.mcode = http_to_coap_code(code)
      response.payload = new_body
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

    def coap_to_http_method(method)
      method.to_s.upcase
    end

    def handle_input(data, sender)
      _, port, host = sender
      request = CoAP::Message.parse(data)

      logger.info "[#{host}]:#{port}: #{request}"
      logger.debug request.inspect

      response = app_response(host, port, request)

      logger.debug response.inspect

      answer(host, port, response)
    end

    def http_to_coap_code(code)
      code = code.to_i

      h = {200 => 205}
      code = h[code] if h[code]

      a = code / 100
      b = code - (a * 100)

      [a, b]
    end

    def initialize_response(request)
      CoAP::Message.new \
        tt: :ack,
        mcode: 2.00,
        mid: request.mid,
        token: request.options[:token]
    end

    def setup_logger(debug)
      logger = ::Logger.new($stderr)
      logger.level = debug ? ::Logger::DEBUG : ::Logger::INFO
      logger.formatter = proc do |sev, time, prog, msg|
        "#{time.strftime('[%Y-%m-%d %H:%M:%S]')} #{sev}  #{msg}\n"
      end

      Celluloid.logger = logger

      logger
    end
  end
end
