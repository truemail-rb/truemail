require 'truemail/version'
require 'truemail/exceptions'
require 'truemail/configuration'

module Truemail
  class << self
    attr_accessor :configuration

    def configure
      return unless block_given?
      self.configuration ||= Configuration.new
      yield(configuration)
      raise ConfigurationError, ConfigurationError::INCOMPLETE_CONFIG unless configuration.complete?
      configuration
    end
  end
end
