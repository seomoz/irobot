require 'null_object'

module Irobot
  module Logger
    def logger
      @logger ||= Irobot.config.fetch(:logger, ::NullObject.new)
    end
  end
end
