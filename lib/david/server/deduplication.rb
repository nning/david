module David
  module Deduplication
    def self.included(base)
      attr_reader :dedup_cache
    end

    def cache_response(request, response)
      return if duplicate?(request)
      @dedup_cache[[request.host, request.mid]] = [response, Time.now.to_i]
    end

    def cached_response(request)
      response = @dedup_cache[[request.host, request.mid]]
      [response[0], response[0].options] if response
    end

    def duplicate?(request)
      return !!cached_response(request)
    end
  end
end
