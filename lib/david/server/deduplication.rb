module David
  module Deduplication
    class Key < Struct.new(:host, :mid)
      def initialize(request)
        self.host = request.host
        self.mid  = request.mid
      end
    end

    def cache_response(request, response)
      return if duplicate?(request)
      @dedup_cache[Key.new(request)] = response
    end

    def cached_response(request)
      response = @dedup_cache[Key.new(request)]
      [response, response.try(:options)]
    end

    def duplicate?(request)
      return !cached_response(request).first.nil?
    end
  end
end
