# frozen_string_literal: true

require 'truemail/core'

module Truemail
  INCOMPLETE_CONFIG = 'verifier_email is required parameter'
  NOT_CONFIGURED = 'use Truemail.configure before'

  class << self
    def configuration
      @configuration ||= begin
        return unless block_given?
        configuration = Truemail::Configuration.new
        yield(configuration)
        raise_unless(configuration.complete?, INCOMPLETE_CONFIG)
        configuration
      end
    end

    def configure(&block)
      configuration(&block)
    end

    def reset_configuration!
      @configuration = nil
    end

    def validate(email, **options)
      raise_unless(configuration, NOT_CONFIGURED)
      Truemail::Validator.new(email, **options).run
    end

    def valid?(email, **options)
      validate(email, **options).result.valid?
    end

    def host_audit
      raise_unless(configuration, NOT_CONFIGURED)
      Truemail::Auditor.new
    end

    private

    def raise_unless(condition, message)
      raise ConfigurationError, message unless condition
    end
  end
end
