require File.dirname(__FILE__) + "/lib/version"

Gem::Specification.new do |spec|
  spec.name = 'irobot'
  spec.version = Irobot::VERSION
  spec.summary = 'Parse robots.txt file'
  spec.authors  = ['Moz']
  spec.email    = 'help@moz.com'
  spec.homepage = 'http://github.com/seomoz/irobot'

  spec.files = `git ls-files`.split($/)
  spec.test_files = spec.files.select{|f| f if f =~ /spec\.rb$/}
  spec.require_paths = ['lib']

  spec.add_runtime_dependency('hashie', '>= 2.0.5')

  spec.add_development_dependency('rspec')
  spec.add_development_dependency('vcr')
  spec.add_development_dependency('webmock')
end
