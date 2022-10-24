# frozen_string_literal: true

require 'truemail/rspec'

# TODO: remove this part in next release
module Truemail
  module RSpec
    module ValidatorHelper
      VALIDATION_LIST_TYPE_REGEX_PATTERN = /(emails|domains)(_list)/.freeze

      class ValidatorFactory
        private

        def process_validator_params # rubocop:disable Metrics/AbcSize
          case validation_type
          when Truemail::RSpec::ValidatorHelper::VALIDATION_LIST_TYPE_REGEX_PATTERN
            list_type = validation_type[Truemail::RSpec::ValidatorHelper::VALIDATION_LIST_TYPE_REGEX_PATTERN, 1]
            self.validation_type = nil
            method = success ? :"whitelisted_#{list_type}" : :"blacklisted_#{list_type}"
            configuration.tap do |config|
              config.public_send(method) << (list_type.eql?('emails') ? email : email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3])
            end
          when :mx_blacklist
            configuration.blacklisted_mx_ip_addresses.push(*mail_servers) unless success
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Truemail::RSpec
end
