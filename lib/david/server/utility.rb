module David
  class Server
    module Utility
      protected

      # This can only use each on body and currently does not support streaming.
      def body_to_string(body)
        s = ''
        body.each { |line| s << line << "\r\n" }
        body.close if body.respond_to?(:close)
        s.chomp
      end
    end
  end
end
