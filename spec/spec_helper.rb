require 'bundler/setup'
Bundler.setup

require 'irobot'
require 'pry'
require 'logger'
require 'irobot/logger'

Irobot.configure do |c|
  c.respect_crawl_delay = false
  c.logger = Logger.new(STDOUT)
end

