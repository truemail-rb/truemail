# frozen_string_literal: true

module Truemail
  require_relative '../truemail/version'
  require_relative '../truemail/configuration'
  require_relative '../truemail/worker'
  require_relative '../truemail/executor'
  require_relative '../truemail/wrapper'
  require_relative '../truemail/auditor'
  require_relative '../truemail/validator'
  require_relative '../truemail/logger'

  ConfigurationError = ::Class.new(::StandardError)
  TypeError = ::Class.new(::StandardError)
  ArgumentError = ::Class.new(::StandardError) do
    def initialize(arg_value, arg_name)
      super("#{arg_value} is not a valid #{arg_name}")
    end
  end

  module RegexConstant
    REGEX_DOMAIN = /[\p{L}0-9]+([\-.]{1}[\p{L}0-9]+)*\.\p{L}{2,63}/i.freeze
    REGEX_SIMPLE_EMAIL_PATTERN = /\w+@\w+/.freeze
    REGEX_EMAIL_PATTERN = %r{(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w\p{L}.+!~,'&%#*^`{}|\-/?=$]*)@(#{REGEX_DOMAIN})\z)}.freeze
    REGEX_DOMAIN_PATTERN = /(?=\A.{4,255}\z)(\A#{REGEX_DOMAIN}\z)/.freeze
    REGEX_DOMAIN_FROM_EMAIL = /\A.+@(.+)\z/.freeze
    REGEX_SMTP_ERROR_BODY_PATTERN = /(?=.*550)(?=.*(user|account|customer|mailbox)).*/i.freeze
    REGEX_IP_ADDRESS = /((1\d|[1-9]|2[0-4])?\d|25[0-5])(\.\g<1>){3}/.freeze
    REGEX_IP_ADDRESS_PATTERN = /\A#{REGEX_IP_ADDRESS}\z/.freeze
    REGEX_PORT_NUMBER = /6553[0-5]|655[0-2]\d|65[0-4](\d){2}|6[0-4](\d){3}|[1-5](\d){4}|[1-9](\d){0,3}/.freeze
    REGEX_DNS_SERVER_ADDRESS_PATTERN = /\A#{REGEX_IP_ADDRESS}(:#{REGEX_PORT_NUMBER})?\z/.freeze
  end

  module Dns
    require_relative '../truemail/dns/punycode_representer'
    require_relative '../truemail/dns/worker'
    require_relative '../truemail/dns/resolver'
  end

  module Audit
    require_relative '../truemail/audit/base'
    require_relative '../truemail/audit/ip'
    require_relative '../truemail/audit/dns'
    require_relative '../truemail/audit/ptr'
  end

  module Validate
    require_relative '../truemail/validate/base'
    require_relative '../truemail/validate/list_match'
    require_relative '../truemail/validate/regex'
    require_relative '../truemail/validate/mx'
    require_relative '../truemail/validate/mx_blacklist'
    require_relative '../truemail/validate/smtp'
    require_relative '../truemail/validate/smtp/response'
    require_relative '../truemail/validate/smtp/request'
  end

  module Log
    require_relative '../truemail/log/event'
    require_relative '../truemail/log/serializer/base'
    require_relative '../truemail/log/serializer/auditor_json'
    require_relative '../truemail/log/serializer/validator_base'
    require_relative '../truemail/log/serializer/validator_text'
    require_relative '../truemail/log/serializer/validator_json'
  end
end
