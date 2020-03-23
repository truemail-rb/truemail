# frozen_string_literal: true

module Truemail
  require 'truemail/version'
  require 'truemail/configuration'
  require 'truemail/worker'
  require 'truemail/wrapper'
  require 'truemail/auditor'
  require 'truemail/validator'
  require 'truemail/logger'

  ConfigurationError = Class.new(StandardError)

  ArgumentError = Class.new(StandardError) do
    def initialize(arg_value, arg_name)
      super("#{arg_value} is not a valid #{arg_name}")
    end
  end

  PunycodeRepresenter = Class.new do
    require 'simpleidn'

    def self.call(email)
      return unless email.is_a?(String)
      return email if email.ascii_only?
      user, domain = email.split('@')
      "#{user}@#{SimpleIDN.to_ascii(domain.downcase)}"
    end
  end

  module RegexConstant
    REGEX_DOMAIN = /[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}/i.freeze
    REGEX_EMAIL_PATTERN = /(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@(#{REGEX_DOMAIN})\z)/.freeze
    REGEX_DOMAIN_PATTERN = /(?=\A.{4,255}\z)(\A#{REGEX_DOMAIN}\z)/.freeze
    REGEX_DOMAIN_FROM_EMAIL = /\A.+@(.+)\z/.freeze
    REGEX_SMTP_ERROR_BODY_PATTERN = /(?=.*550)(?=.*(user|account|customer|mailbox)).*/i.freeze
  end

  module Audit
    require 'truemail/audit/base'
    require 'truemail/audit/ptr'
  end

  module Validate
    require 'truemail/validate/base'
    require 'truemail/validate/domain_list_match'
    require 'truemail/validate/regex'
    require 'truemail/validate/mx'
    require 'truemail/validate/smtp'
    require 'truemail/validate/smtp/response'
    require 'truemail/validate/smtp/request'
  end

  module Log
    require 'truemail/log/event'
    require 'truemail/log/serializer/base'
    require 'truemail/log/serializer/text'
    require 'truemail/log/serializer/json'
  end
end
