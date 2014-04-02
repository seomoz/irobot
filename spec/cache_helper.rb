require 'irobot'

class RequestCacheTest
  NAMESPACE = 'request_spec'

  attr_accessor :cache
  def initialize
    @cache = {}
  end

  def get(request)
    if cache.has_key?(request.to_key)
      Marshal::load(cache[request.to_key])
    end
  end

  def set(request, response, details = {})
    cache[request.to_key] = Marshal::dump(response)
  end
end
