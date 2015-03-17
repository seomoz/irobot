require 'irobot/logger'
require 'irobot/response'

module Irobot
  class TxtParser
    include Logger

    attr_accessor :robots_txt, :user_agent
    def initialize(robots_txt, absolute_path, user_agent)
      @robots_txt = robots_txt
      @absolute_path = absolute_path
      @user_agent = user_agent

      @other = {}
      @disallows = {}
      @allows = {}
      @delays = {} # added delays to make it work
      agent = /.*/

      robots_txt.split("\n").each do |line|
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

      @parsed = true
    end

    def allowed?
      return true unless @parsed
      allowed = true

      @disallows.each do |user_agent_regex, disallows|
        if user_agent.match(user_agent_regex)
          disallows.each do |disallow_regex|
            if path.match(disallow_regex)
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

      if allowed && respect_crawl_delay?
        @delays.each do |ua_regex, ttl|
          sleep(ttl) if user_agent.match(ua_regex)
        end
      end

      allowed
    end

    def other_values
      @other
    end

  protected
    def respect_crawl_delay?
      Irobot.config.respect_crawl_delay
    end

    def to_regex(pattern)
      return /should-not-match-anything-123456789/ if pattern.strip.empty?

      pattern = Regexp.escape(pattern)

      # Throw a wildcard at the end of the pattern if we are using parameters
      # (and it does not already have a wildcard at the end)
      pattern << '*' if pattern.match(/\?*[^\*]$/)

      pattern.gsub!(Regexp.escape("*"), ".*")

      # [jason@moz.com] There seems to be a problem with the matching logic.
      # For example, if '/foo' is disallowed, '/foobar' will also be disallowed.
      # I will circle back and fix this, but for now, strip the trailing / so that
      # requests to directories which do not have the trailing slash match
      # disallow values that do include a trailing slash.
      pattern.gsub!(/(.*)\/$/, '\1')

      Regexp.compile("^#{pattern}")
    end

    def uri
      @uri ||= begin
        @absolute_path.is_a?(URI) ? @absolute_path : URI.parse(@absolute_path)
      rescue URI::InvalidURIError
        logger.warn "Request path #{@absolute_path} raised URI::InvalidURIError: #{e}"
      end
    end

    def path
      @path ||= begin
        # if we do not give an abs path, then URI.parse will give us a URI::Generic
        # object back. If we do, then we get back a URI::HTTP obj.
        p = case uri
        when URI::Generic then uri.path
        when URI::HTTP then uri.request_uri
        end

        p.empty? ? '/' : p
      end
    end
  end
end
