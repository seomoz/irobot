require 'irobot'
require 'logger'
require 'yaml'

class SimpleRedisCache
  DEFAULT_TTL = 60*60*24

  def initialize(options = {})
    @hashie = Hashie::Mash.new #OSE.redis_for(:cache)
  end

  def get(request)
    if @hashie.has_key?(request.to_key)
      Marshal::load(@hashie[request.to_key])
    end
  end

  def set(request, response)
    begin
      @hashie[request.to_key] = Marshal::dump(response)
    rescue => e
      binding.pry
    end
  end

private

  def ttl
    @options.fetch(:ttl, DEFAULT_TTL)
  end

end


Irobot.configure do |c|
  c.timeout = 60*5*10
  c.cache = SimpleRedisCache.new(ttl: 60*60*24)
  c.logger = Logger.new(STDOUT)
end

Irobot.allowed?('http://moz.com', 'dotbot')
