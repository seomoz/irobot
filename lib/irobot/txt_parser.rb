require 'irobot/response'

module Irobot
  class TxtParser

    attr_accessor :response
    def initialize(response)
      @response = response

      @other = {}
      @disallows = {}
      @allows = {}
      @delays = {} # added delays to make it work
      agent = /.*/

      @last_accessed = Time.at(1)

      @other = {}
      @disallows = {}
      @allows = {}
      @delays = {} # added delays to make it work

      agent = /.*/

      response.each_line do |line|
        next if line =~ /^\s*(#.*|$)/
        arr = line.split(":")
        key = arr.shift
        value = arr.join(":").strip
        value.strip!

        case key
        when "User-agent"
          agent = to_regex(value)
        when "Allow"
          @allows[agent] ||= []
          @allows[agent] << to_regex(value)
        when "Disallow"
          @disallows[agent] ||= []
          @disallows[agent] << to_regex(value)
        when "Crawl-delay"
          @delays[agent] = value.to_i
        else
          @other[key] ||= []
          @other[key] << value
        end
      end
    end

    def user_agent
      response.user_agent
    end

    def allowed?
      allowed = true
      path = response.request_uri

      @disallows.each do |key, value|
        if user_agent =~ key
          value.each do |rule|
            if path =~ rule
              allowed = false
            end
          end
        end
      end

      @allows.each do |key, value|
        unless allowed
          if user_agent =~ key
            value.each do |rule|
              if path =~ rule
                allowed = true
              end
            end
          end
        end
      end

      if allowed && @delays[user_agent]
        sleep @delays[user_agent] - (Time.now - @last_accessed)
        @last_accessed = Time.now
      end

      return allowed
    end

    def other_values
      @other
    end

  protected

    def to_regex(pattern)
      return /should-not-match-anything-123456789/ if pattern.strip.empty?
      pattern = Regexp.escape(pattern)
      pattern.gsub!(Regexp.escape("*"), ".*")
      Regexp.compile("^#{pattern}")
    end
  end
end
