# frozen_string_literal: true

require 'truemail/core'

module Truemail
  INCOMPLETE_CONFIG = 'verifier_email is required parameter'
  NOT_CONFIGURED = 'use Truemail.configure before or pass custom configuration'

  class << self
    def configuration
      @configuration ||= begin
        return unless block_given?
        configuration = Truemail::Configuration.new
        yield(configuration)
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
      Truemail::Validator.new(email, configuration: determine_configuration(custom_configuration), **options).run
    end

    def valid?(email, **options)
      validate(email, **options).result.valid?
    end

    def host_audit(custom_configuration: nil)
      Truemail::Auditor.new(configuration: determine_configuration(custom_configuration)).run
    end

    private

    def raise_unless(condition, message)
      raise Truemail::ConfigurationError, message unless condition
    end

    def determine_configuration(custom_configuration)
      current_configuration = custom_configuration || configuration
      raise_unless(current_configuration, Truemail::NOT_CONFIGURED)
      raise_unless(current_configuration.complete?, Truemail::INCOMPLETE_CONFIG)
      current_configuration.dup.freeze
    end
  end
end
