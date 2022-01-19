# frozen_string_literal: true

require 'smtp_mock/test_framework/rspec'

RSpec.configure do |config|
  config.include SmtpMock::TestFramework::RSpec::Helper
end
