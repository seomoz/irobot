require 'hashie'
require 'open-uri'
require 'timeout'
require 'uri'

require 'irobot/faux_response'
require 'irobot/logger'
require 'irobot/response'

module Irobot
  class Request
    include Logger

    def self.allowed?(uri, user_agent)
      new(uri, user_agent).allowed?
    end

    attr_accessor :uri, :user_agent, :options
    def initialize(uri, user_agent, options = {})
      @uri = uri
      @user_agent = user_agent
      @options = options
    end

    def to_key
      [cache_namespace, uri, user_agent].join('::')
    end

    # If you need to bypass cache, use the bang version
    def response
      @response ||= request!(true)
    end

    def request!(use_cache = false)
      begin
        Timeout::timeout(timeout) do
          txt = request_robots_txt!(use_cache)
          Irobot::Response.new(self, txt)
        end

      rescue Timeout::Error, RuntimeError => e
        logger.warn "Exception when requesting robots.txt: #{e}"
        Irobot::Response.new(self)
      end
    end

    def allowed?
      response.allowed?
    end

  private

    def request_robots_txt!(use_cache)
      parsed_io = get_from_cache if use_cache
      return parsed_io if parsed_io

      start = Time.now
      io = robots_path.open('User-Agent' => user_agent)
      logger.info "Request Time: #{Time.now - start}"
      parsed_io = Irobot::Response.parse_io(io)
      set_cache(parsed_io, use_cache)
    end

    def set_cache(parsed_io, use_cache)
      if cacheable? && use_cache
        logger.info "Set Cache: #{to_key}"
        logger.debug "Cache: #{parsed_io}"
        Irobot.config.cache.set(self, parsed_io)
      end
      parsed_io
    end

    def get_from_cache
      return unless cacheable?

      if parsed_io = Irobot.config.cache.get(self)
        logger.info "Cache Hit: #{to_key}"
        parsed_io
      end
    end

    def cacheable?
      !!Irobot.config.cache
    end

    def timeout
      options.fetch(:timeout, Irobot.config.timeout)
    end

    def cache_namespace
      options.fetch(:cache_namespace, Irobot.config.cache_namespace)
    end

    def robots_path
      URI.join(uri.to_s, '/robots.txt')
    end

  end
end
