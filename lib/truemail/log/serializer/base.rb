# frozen_string_literal: true

module Truemail
  module Log
    module Serializer
      class Base
        DEFAULT_GEM_VALUE = 'default gem value'

        def self.call(validator_instance)
          new(validator_instance).serialize
        end

        def initialize(validator_instance)
          @validation_type = validator_instance.validation_type
          @validation_result = validator_instance.result
          @validation_configuration = validation_result.configuration
        end

        def serialize; end

        private

        attr_reader :validation_type, :validation_result, :validation_configuration

        def errors
          validation_errors = validation_result.errors
          return if validation_errors.empty?
          validation_errors
        end

        def smtp_debug
          validation_smtp_debug = validation_result.smtp_debug
          return unless validation_smtp_debug
          validation_smtp_debug.map do |smtp_request|
            smtp_response = smtp_request.response
            {
              mail_host: smtp_request.host,
              port_opened: smtp_response.port_opened,
              connection: smtp_response.connection,
              errors: smtp_response.errors
            }
          end
        end

        %i[validation_type_by_domain whitelisted_domains blacklisted_domains].each do |method|
          define_method(method) do
            value = validation_configuration.public_send(method)
            return if value.empty?
            value
          end
        end

        %i[email_pattern smtp_error_body_pattern].each do |method|
          define_method(method) do
            value = validation_configuration.public_send(method)
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
            whitelist_validation: validation_configuration.whitelist_validation,
            whitelisted_domains: whitelisted_domains,
            blacklisted_domains: blacklisted_domains,
            smtp_safe_check: validation_configuration.smtp_safe_check,
            email_pattern: email_pattern,
            smtp_error_body_pattern: smtp_error_body_pattern
          }
        end

        def result
          @result ||=
            {
              date: Time.now,
              email: validation_result.email,
              validation_type: validation_type,
              success: validation_result.success,
              errors: errors,
              smtp_debug: smtp_debug,
              configuration: configuration
            }
        end
      end
    end
  end
end
