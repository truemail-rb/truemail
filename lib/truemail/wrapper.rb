# frozen_string_literal: true

module Truemail
  class Wrapper
    attr_accessor :attempts

    def self.call(&block)
      new.call(&block)
    end

    def initialize
      @attempts = Truemail.configuration.connection_attempts
    end

    def call(&block)
      Timeout.timeout(Truemail.configuration.connection_timeout, &block)
    rescue Resolv::ResolvError, IPAddr::InvalidAddressError
      false
    rescue Timeout::Error
      retry unless (self.attempts -= 1).zero?
      false
    end
  end
end
