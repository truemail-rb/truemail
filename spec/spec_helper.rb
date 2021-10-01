# frozen_string_literal: true

require 'bundler/setup'
require_relative 'support/config/simplecov'
require_relative '../lib/truemail'

rspec_custom = ::File.join(::File.dirname(__FILE__), 'support/**/*.rb')
::Dir[::File.expand_path(rspec_custom)].each { |file| require file unless file[/\A.+_spec\.rb\z/] }

RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
RSpec.configure do |config|
  config.include Truemail::ContextHelper
  config.include Truemail::DnsHelper
  config.include Truemail::IpifyHelper
  config.order = :random
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.before { Truemail.reset_configuration! }

  ::Kernel.srand(config.seed)
end
