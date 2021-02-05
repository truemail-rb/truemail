# frozen_string_literal: true

module Truemail
  class Wrapper
    attr_reader :timeout
    attr_accessor :attempts

    def self.call(configuration:, &block)
      new(configuration).call(&block)
    end

    def initialize(configuration)
      @attempts = configuration.connection_attempts
      @timeout = configuration.connection_timeout
    end

    def call(&block)
      ::Timeout.timeout(timeout, &block)
    rescue ::Resolv::ResolvError, ::IPAddr::InvalidAddressError
      false
    rescue ::Timeout::Error
      retry unless (self.attempts -= 1).zero?
      false
    end
  end
end
