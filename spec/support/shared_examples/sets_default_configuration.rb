# frozen_string_literal: true

module Truemail
  RSpec.shared_examples 'sets default configuration' do
    it 'sets default configuration settings' do
      expect(configuration_instance.email_pattern).to eq(Truemail::RegexConstant::REGEX_EMAIL_PATTERN)
      expect(configuration_instance.smtp_error_body_pattern).to eq(Truemail::RegexConstant::REGEX_SMTP_ERROR_BODY_PATTERN)
      expect(configuration_instance.verifier_email).to be_nil
      expect(configuration_instance.verifier_domain).to be_nil
      expect(configuration_instance.connection_timeout).to eq(Truemail::Configuration::DEFAULT_CONNECTION_TIMEOUT)
      expect(configuration_instance.response_timeout).to eq(Truemail::Configuration::DEFAULT_RESPONSE_TIMEOUT)
      expect(configuration_instance.connection_attempts).to eq(Truemail::Configuration::DEFAULT_CONNECTION_ATTEMPTS)
      expect(configuration_instance.default_validation_type).to eq(Truemail::Configuration::DEFAULT_VALIDATION_TYPE)
      expect(configuration_instance.validation_type_by_domain).to eq({})
      expect(configuration_instance.whitelisted_domains).to eq([])
      expect(configuration_instance.blacklisted_domains).to eq([])
      expect(configuration_instance.smtp_safe_check).to be(false)
    end
  end
end
