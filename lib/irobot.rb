require 'irobot/request'

module Irobot
  DEFAULT_TIMEOUT_IN_SECONDS = 3
  DEFAULT_CACHE_NAMESPACE = 'irobot'
  RESPECT_CRAWL_DELAY = true

  def self.config
    @config ||= Hashie::Mash.new(
      timeout: DEFAULT_TIMEOUT_IN_SECONDS,
      cache_namespace: DEFAULT_CACHE_NAMESPACE,
      respect_crawl_delay: RESPECT_CRAWL_DELAY
    )
  end

  def self.configure
    yield config
  end

  def self.allowed?(uri, user_agent)
    Request.new(uri, user_agent).allowed?
  end
end
