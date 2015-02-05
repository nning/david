module David
  class ShowExceptions
    def initialize(app)
      @app = app
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      @app.call(env)
    rescue Exception => exception
      if env['action_dispatch.show_exceptions'] == false
        raise exception
      end

      @env = env

      render_exception(exception)
    end

    private

    def render_exception(e)
      body = {
        error:    e.class.to_s,
        message:  e.message
      }

      log.error([body[:error], body[:message]].join(': '))
      
      body = body.to_json

      code = if defined?(ActiveRecord) && e.is_a?(ActiveRecord::RecordNotFound)
        404
      elsif e.is_a?(ActionController::RoutingError)
        404
      else
        500
      end

      [code,
        {
          'Content-Type' => 'application/json',
          'Content-Length' => body.bytesize.to_s
        },
        [body]
      ]
    end

    def log
      @logger ||= @env['rack.logger']
    end
  end
end
