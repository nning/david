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

    def render_exception(exception)
      body = {
        error: exception.class.to_s,
        message: exception.message
      }

      log(:info, [body[:error], body[:message]].join("\n"))
      
      body = body.to_json

      code = 500
      code = 404 if exception.is_a?(ActiveRecord::RecordNotFound)

      [code,
        {
          'Content-Type' => 'application/json',
          'Content-Length' => body.bytesize.to_s
        },
        [body]
      ]
    end

    def log(level, message)
      @logger ||= @env['rack.logger']
      @logger.send(level, message) if @logger
    end
  end
end
