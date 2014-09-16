module David
  class Server
    module Utility
      protected

      # This can only use each on body and currently does not support streaming.
      def body_to_string(body)
        s = ''
        body.each { |line| s += line + "\r\n" }
        s.chomp
      end

      def content_type(options)
        ct = options['Content-Type']
        ct.split(';').first unless ct.nil?
      end
    end
  end
end
