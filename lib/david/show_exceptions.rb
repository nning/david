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
      else
        render_exception(env, exception)
      end
    end

    private

    def render_exception(env, exception)
      body = {
        error: exception.class.to_s,
        message: exception.message
      }
      
      body = body.to_json

      [500,
        {
          'Content-Type' => 'application/json',
          'Content-Length' => body.bytesize.to_s
        },
        [body]
      ]
    end
  end
end
