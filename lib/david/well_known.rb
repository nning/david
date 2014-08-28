module David
  class WellKnown
    def initialize(app)
      @app = app
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      if env['PATH_INFO'] == '/.well-known/core'
        links = filtered_paths.map { |path| CoRE::Link.new(path) }
        
        [200,
          {'Content-Type' => 'application/link-format'},
          [links.map(&:to_s).join(',')]
        ]
      else
        @app.call(env)
      end
    end

    private

    def delete_format(spec)
      spec.gsub(/\(\.:format\)\z/, '')
    end

    def filtered_paths
      @filtered_paths ||= specs
        .select { |spec| spec if include_spec?(spec) }
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
