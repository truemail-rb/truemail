# frozen_string_literal: true

module Truemail
  module Log
    module Serializer
      class Base
        require 'json'

        CONFIGURATION_ARRAY_ATTRS = %i[
          validation_type_by_domain
          whitelisted_emails
          blacklisted_emails
          whitelisted_domains
          blacklisted_domains
          blacklisted_mx_ip_addresses
          dns
        ].freeze
        CONFIGURATION_REGEX_ATTRS = %i[email_pattern smtp_error_body_pattern].freeze
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

        Truemail::Log::Serializer::Base::CONFIGURATION_ARRAY_ATTRS.each do |method|
          define_method(method) do
            executor_configuration_attr = executor_configuration.public_send(method)
            return if executor_configuration_attr.empty?
            executor_configuration_attr
          end
        end

        Truemail::Log::Serializer::Base::CONFIGURATION_REGEX_ATTRS.each do |method|
          define_method(method) do
            executor_configuration_attr = executor_configuration.public_send(method)
            default_pattern = Truemail::RegexConstant.const_get(
              (method.eql?(:email_pattern) ? :regex_email_pattern : :regex_smtp_error_body_pattern).upcase
            )
            return Truemail::Log::Serializer::Base::DEFAULT_GEM_VALUE if executor_configuration_attr.eql?(default_pattern)
            executor_configuration_attr
          end
        end

        def configuration
          {
            validation_type_by_domain: validation_type_by_domain,
            whitelist_validation: executor_configuration.whitelist_validation,
            whitelisted_emails: whitelisted_emails,
            blacklisted_emails: blacklisted_emails,
            whitelisted_domains: whitelisted_domains,
            blacklisted_domains: blacklisted_domains,
            blacklisted_mx_ip_addresses: blacklisted_mx_ip_addresses,
            dns: dns,
            not_rfc_mx_lookup_flow: executor_configuration.not_rfc_mx_lookup_flow,
            smtp_fail_fast: executor_configuration.smtp_fail_fast,
            smtp_safe_check: executor_configuration.smtp_safe_check,
            email_pattern: email_pattern,
            smtp_error_body_pattern: smtp_error_body_pattern
          }
        end
      end
    end
  end
end
