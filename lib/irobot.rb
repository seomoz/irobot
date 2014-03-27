require 'irobot/configuration'
require 'irobot/request'

module Irobot
  DEFAULT_TIMEOUT = 3
  DEFAULT_CACHE_NAMESPACE = 'irobot'

  def self.config
    @config ||= Hashie::Mash.new(
      timeout: DEFAULT_TIMEOUT,
      cache_namespace: DEFAULT_CACHE_NAMESPACE
    )
  end

  def self.configure
    yield config
  end

  def self.allowed?(uri, user_agent)
    Request.new(uri, user_agent).allowed?
  end
end
