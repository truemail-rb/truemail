module Truemail
  class ConfigurationError < StandardError
    INCOMPLETE_CONFIG = 'verifier_email is required parameter'.freeze
  end
end
