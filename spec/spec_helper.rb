require 'bundler/setup'
Bundler.setup

require 'pry'
require 'logger'
require 'vcr'

require 'irobot'
require 'irobot/logger'

Irobot.configure do |c|
  c.respect_crawl_delay = false
  c.logger = Logger.new(STDOUT)
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
end

RSpec.configure do |c|
  c.extend VCR::RSpec::Macros
end
