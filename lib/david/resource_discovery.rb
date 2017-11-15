require 'david/server/constants'

module David
  class ResourceDiscovery
    include Celluloid
    include David::Server::Constants

    def initialize(app)
      @app = app
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      return @app.call(env) if env['PATH_INFO']      != '/.well-known/core'
      return [405, {}, []]  if env['REQUEST_METHOD'] != 'GET'

      @env = env

      filtered = routes_hash.select { |link| filter(link) }
      body     = filtered.keys.map(&:to_s).join(',')

      # TODO On multicast, do not respond if result set empty.

      [
        200,
        {
          'Content-Type'   => 'application/link-format',
          'Content-Length' => body.bytesize.to_s
        },
        [body]
      ]
    end

    def register(controller, options)
      name    = controller.controller_name
      default = options.delete(:default)

      routes_hash.each do |link, route|
        next unless route[:controller] == name

        link.merge!(default) unless default.nil?

        attrs = options[route[:action].to_sym]
        link.merge!(attrs) unless attrs.nil?
      end
    end

    private

    def clean_routes
      @clean_routes ||= routes
        .uniq   { |r| r[0] }
        .select { |r| r if include_route?(r) }
        .each   { |r| delete_format!(r) }
    end

    def resource_links
      Hash[routes.collect { |r| [r[3], r[4]] }]
    end

    def delete_format!(route)
      route[0].gsub!(/\(\.:format\)\z/, '')
    end

    def filter(link)
      href = @env['QUERY_STRING'].split('href=').last

      return true if href.blank?

      # TODO If query end in '*', match on prefix.
      #      Otherwise match on whole string.
      #      https://tools.ietf.org/html/rfc6690#section-4.1
      link.uri =~ Regexp.new(href)
    end

    def include_route?(route)
      !(route[0] =~ /\A\/(assets|rails|cable)/)
    end

    def routes
      Rails.application.routes.routes.select { |route|
        route.defaults[:coap]
      }.map do |route|
        [
          route.path.spec.to_s,
          route.defaults[:controller],
          route.defaults[:action],
          route.defaults[:rt],
          route.defaults[:short]
        ]
      end
    end

    def routes_hash
      @routes_hash ||= Hash[clean_routes.collect { |r|
        [CoRE::Link.new(r[0]), { controller: r[1], action: r[2] }]
      }]
    end
  end
end
