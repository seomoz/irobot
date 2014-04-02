module Irobot
  class Response
    module RobotsAllow
      ROBOTS_ALLOW_STR = "User-agent: *\nAllow: /\n"

      def dummy_io
        StringIO.new(ROBOTS_ALLOW_STR)
      end
    end
  end
end
