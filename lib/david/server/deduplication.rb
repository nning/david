module David
  module Deduplication
    def cache_response(request, response)
      return if duplicate?(request)
      @dedup_cache[[request.host, request.mid]] = response
    end

    def cached_response(request)
      response = @dedup_cache[[request.host, request.mid]]
      [response, response.options] if response
    end

    def duplicate?(request)
      return !!cached_response(request)
    end
  end
end
