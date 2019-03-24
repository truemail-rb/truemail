# frozen_string_literal: true

require 'truemail/version'
require 'truemail/core'
require 'truemail/configuration'
require 'truemail/validator'

module Truemail
  INCOMPLETE_CONFIG = 'verifier_email is required parameter'
  NOT_CONFIGURED = 'use Truemail.configure before'

  class << self
    def configuration
      @configuration ||= begin
        return unless block_given?
        configuration = Truemail::Configuration.new
        yield(configuration)
        raise ConfigurationError, INCOMPLETE_CONFIG unless configuration.complete?
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
      raise ConfigurationError, NOT_CONFIGURED unless configuration
      Truemail::Validator.new(email, **options).run
    end
  end
end
