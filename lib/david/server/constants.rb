module David
  class Server
    module Constants
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

      # Freeze CoAP specific env keys.
      COAP_VERSION    = 'coap.version'.freeze
      COAP_MULTICAST  = 'coap.multicast'.freeze
      COAP_CBOR       = 'coap.cbor'.freeze
      COAP_DTLS       = 'coap.dtls'.freeze
      COAP_DTLS_ID    = 'coap.dtls.id'.freeze
      COAP_DTLS_NOSEC = 'NoSec'.freeze

      # Freeze some Rack env values.
      EMPTY_STRING          = ''.freeze
      CONTENT_TYPE_JSON     = 'application/json'.freeze
      CONTENT_TYPE_CBOR     = 'application/cbor'.freeze
      RACK_URL_SCHEME_HTTP  = 'http'.freeze

      # Freeze HTTP header strings.
      HTTP_CACHE_CONTROL  = 'Cache-Control'.freeze
      HTTP_CONTENT_LENGTH = 'Content-Length'.freeze
      HTTP_CONTENT_TYPE   = 'Content-Type'.freeze
      HTTP_ETAG           = 'ETag'.freeze
      HTTP_LOCATION       = 'Location'.freeze
    end
  end
end
