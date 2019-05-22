# frozen_string_literal: true

module Truemail
  require 'truemail/version'
  require 'truemail/configuration'
  require 'truemail/worker'
  require 'truemail/wrapper'
  require 'truemail/auditor'
  require 'truemail/validator'

  class ConfigurationError < StandardError; end

  class ArgumentError < StandardError
    def initialize(current_param, class_name)
      super("#{current_param} is not a valid #{class_name}")
    end
  end

  module RegexConstant
    REGEX_DOMAIN = /[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,63}/i
    REGEX_EMAIL_PATTERN = /(?=\A.{6,255}\z)(\A([a-zA-Z0-9]+[\w|\-|\.|\+]*)@(#{REGEX_DOMAIN})\z)/
    REGEX_DOMAIN_PATTERN = /(?=\A.{4,255}\z)(\A#{REGEX_DOMAIN}\z)/
    REGEX_DOMAIN_FROM_EMAIL = /\A.+@(.+)\z/
    REGEX_SMTP_ERROR_BODY_PATTERN = /(?=.*550)(?=.*(user|account|customer|mailbox)).*/i
  end

  module Audit
    require 'truemail/audit/base'
    require 'truemail/audit/ptr'
  end

  module Validate
    require 'truemail/validate/skip'
    require 'truemail/validate/base'
    require 'truemail/validate/regex'
    require 'truemail/validate/mx'
    require 'truemail/validate/smtp'
    require 'truemail/validate/smtp/response'
    require 'truemail/validate/smtp/request'
  end
end
