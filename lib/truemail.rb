require 'truemail/version'
require 'truemail/exceptions'
require 'truemail/configuration'

module Truemail
  def self.configuration
    @configuration ||= begin
      return unless block_given?
      configuration = Configuration.new
      yield(configuration)
      raise ConfigurationError, ConfigurationError::INCOMPLETE_CONFIG unless configuration.complete?
      configuration
    end
  end

  def self.configure(&block)
    configuration(&block)
  end
end
