# frozen_string_literal: true

module Truemail
  class ConfigurationError < StandardError; end

  class ArgumentError < StandardError
    def initialize(current_param, class_name)
      super("#{current_param} is not a valid #{class_name}")
    end
  end

  module RegexConstant
    REGEX_DOMAIN = /[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,7}/
    REGEX_EMAIL_PATTERN = /(?=\A.{6,255}\z)(\A([\w|\-|\.]+)@(#{REGEX_DOMAIN})\z)/
    REGEX_DOMAIN_PATTERN = /(?=\A.{4,255}\z)(\A#{REGEX_DOMAIN}\z)/
  end

  module Validate
    require 'truemail/validate/base'
    require 'truemail/validate/regex'
    require 'truemail/validate/mx'
    require 'truemail/validate/smtp'
    require 'truemail/validate/smtp/response'
    require 'truemail/validate/smtp/request'
  end
end
