## irobot

![Team Shared Services](https://img.shields.io/badge/team-shared_services-green.svg?style=flat)
![Status Production](https://img.shields.io/badge/status-production-green.svg?style=flat)
![Open Source](https://img.shields.io/badge/open_source-yes-green.svg?style=flat)
![Critical True](https://img.shields.io/badge/critical-true-red.svg?style=flat)

A `robots.txt` file inspector.

#### Configuration

An example of some common config options include:

```ruby
require 'simple_redis_cache'

Irobot.configure do |c|
  c.timeout = 1 # second
  c.cache_namespace
  c.cache = SimpleRedisCache.new(ttl: 1.day)
  c.logger = Logger.new(File.join(ROOT, 'log', 'irobot.log'))

  # Since we aren't actually crawling the site, we'll ignore crawl delays
  c.respect_crawl_delay = false
end
```

#### Usage

```ruby
--- moz/irobot » bundle exec pry
[1] pry(main)> require 'irobot';
[2] pry(main)> Irobot.allowed?('http://amazon.com', 'EtaoSpider')
=> false
[3] pry(main)> Irobot.allowed?('http://moz.com', 'mozbot')
=> true
```
