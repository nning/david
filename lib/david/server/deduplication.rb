module David
  module Deduplication
    def cache_response(request, response)
      return if duplicate?(request)
      @dedup_cache[[request.host, request.mid]] = response
    end

    def cached_response(request)
      response = @dedup_cache[[request.host, request.mid]]
      [response, response.try(:options)]
    end

    def duplicate?(request)
      return !cached_response(request).first.nil?
    end
  end
end
