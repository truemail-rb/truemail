require 'bundler/setup'
require 'ffaker'
require 'pry'
require 'truemail'

rspec_custom = File.join(File.dirname(__FILE__), 'support/**/*.rb')
Dir[File.expand_path(rspec_custom)].each { |file| require file }

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.include Truemail::ConfigurationHelper
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
