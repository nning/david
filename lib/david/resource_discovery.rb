module David
  class ResourceDiscovery
    include Celluloid

    def initialize(app)
      @app = app
      Celluloid::Actor[:discovery] = Celluloid::Actor.current
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      if env['PATH_INFO'] == '/.well-known/core'
        return [405, {}, []] if env['REQUEST_METHOD'] != 'GET'

        @env = env

        links = filtered_paths.map { |path| CoRE::Link.new(path) }
        body  = links.map(&:to_s).uniq.join(',')

        # TODO On multicast, do not respond if result set empty.

        [
          200,
          {
            'Content-Type'   => 'application/link-format',
            'Content-Length' => body.bytesize.to_s
          },
          [body]
        ]
      else
        @app.call(env)
      end
    end

    private

    def delete_format(spec)
      spec.gsub(/\(\.:format\)\z/, '')
    end

    def filter(spec)
      href = @env['QUERY_STRING'].split('href=').last

      return true if href.blank?

      # TODO If query end in '*', match on prefix.
      #      Otherwise match on whole string.
      #      https://tools.ietf.org/html/rfc6690#section-4.1
      spec =~ Regexp.new(href)
    end

    def filtered_paths
      @filtered_paths ||= specs
        .select { |spec| spec if include_spec?(spec) }
        .select { |spec| spec if filter(spec) }
        .map { |spec| delete_format(spec) }
    end

    def include_spec?(spec)
      !(spec == '/' || spec =~ /\A\/(assets|rails)/)
    end

    def specs
      @specs ||= Rails.application.routes.routes.map do |route|
        route.path.spec.to_s
      end
    end
  end
end
