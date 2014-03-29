require 'irobot/response/robots_allow'
require 'irobot/txt_parser'

module Irobot
  class Response
    include Response::RobotsAllow

    # URI::HTTP (OpenURI::OpenRead#method) open returns back a StringIO obj. For
    # cache purposes, convert that to something we can Marshal
    def self.parse_io(io)
      io.string
    end

    # attr_writer :cached
    attr_accessor :request, :robots_txt
    def initialize(request, robots_txt = nil)
      @request = request
      @robots_txt = robots_txt || self.class.parse_io(dummy_io)
    end

    def allowed?
      parsed.allowed?
    end

  private

    def other_values
      parsed.other_values
    end

    def request_uri
      request.uri
    end

    def user_agent
      request.user_agent
    end

    def parsed
      @parsed ||= TxtParser.new(robots_txt, request_uri, user_agent)
    end
  end
end
