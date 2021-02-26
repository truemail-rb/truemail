# frozen_string_literal: true

require 'dns_mock/test_framework/rspec'

RSpec.configure do |config|
  config.include DnsMock::TestFramework::RSpec::Helper
end
