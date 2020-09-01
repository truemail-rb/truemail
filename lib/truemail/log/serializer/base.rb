# frozen_string_literal: true

module Truemail
  module Log
    module Serializer
      class Base
        require 'json'

        DEFAULT_GEM_VALUE = 'default gem value'

        def self.call(executor_instance)
          new(executor_instance).serialize
        end

        def initialize(executor_instance)
          @executor_result = executor_instance.result
          @executor_configuration = executor_result.configuration
        end

        def serialize; end

        private

        attr_reader :executor_result, :executor_configuration

        def errors(executor_result_target)
          return if executor_result_target.empty?
          executor_result_target
        end

        alias warnings errors

        %i[validation_type_by_domain whitelisted_domains blacklisted_domains].each do |method|
          define_method(method) do
            value = executor_configuration.public_send(method)
            return if value.empty?
            value
          end
        end

        %i[email_pattern smtp_error_body_pattern].each do |method|
          define_method(method) do
            value = executor_configuration.public_send(method)
            default_pattern = Truemail::RegexConstant.const_get(
              (method.eql?(:email_pattern) ? :regex_email_pattern : :regex_smtp_error_body_pattern).upcase
            )
            return Truemail::Log::Serializer::Base::DEFAULT_GEM_VALUE if value.eql?(default_pattern)
            value
          end
        end

        def configuration
          {
            validation_type_by_domain: validation_type_by_domain,
            whitelist_validation: executor_configuration.whitelist_validation,
            whitelisted_domains: whitelisted_domains,
            blacklisted_domains: blacklisted_domains,
            not_rfc_mx_lookup_flow: executor_configuration.not_rfc_mx_lookup_flow,
            smtp_safe_check: executor_configuration.smtp_safe_check,
            email_pattern: email_pattern,
            smtp_error_body_pattern: smtp_error_body_pattern
          }
        end
      end
    end
  end
end
