if defined?(RUBY_ENGINE) and (RUBY_ENGINE == 'ruby') and (RUBY_VERSION >= '1.9')
  require 'simplecov'
  SimpleCov.start
end
$:.push(File.join(File.dirname(__FILE__),'..','lib'))
require 'rspec/matchers'
require 'equivalent-xml'
