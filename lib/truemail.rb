# frozen_string_literal: true

require_relative 'truemail/core'

module Truemail
  INCOMPLETE_CONFIG = 'verifier_email is required parameter'
  NOT_CONFIGURED = 'use Truemail.configure before or pass custom configuration'
  INVALID_TYPE = 'email should be a String'

  class << self
    def configuration(&block)
      @configuration ||= begin
        return unless block_given?
        configuration = Truemail::Configuration.new(&block)
        raise_unless(configuration.complete?, Truemail::INCOMPLETE_CONFIG)
        configuration
      end
    end

    def configure(&block)
      configuration(&block)
    end

    def reset_configuration!
      @configuration = nil
    end

    def validate(email, custom_configuration: nil, **options)
      check_argument_type(email)
      Truemail::Validator.new(email, configuration: determine_configuration(custom_configuration), **options).run
    end

    def valid?(email, **options)
      check_argument_type(email)
      validate(email, **options).result.valid?
    end

    def host_audit(custom_configuration: nil)
      Truemail::Auditor.new(configuration: determine_configuration(custom_configuration)).run
    end

    private

    def raise_unless(condition, message, error_class = Truemail::ConfigurationError)
      raise error_class, message unless condition
    end

    def check_argument_type(argument)
      raise_unless(argument.is_a?(String), Truemail::INVALID_TYPE, Truemail::TypeError)
    end

    def determine_configuration(custom_configuration)
      current_configuration = custom_configuration || configuration
      raise_unless(current_configuration, Truemail::NOT_CONFIGURED)
      raise_unless(current_configuration.complete?, Truemail::INCOMPLETE_CONFIG)
      current_configuration.dup.freeze
    end
  end
end
