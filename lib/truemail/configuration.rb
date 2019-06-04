# frozen_string_literal: true

module Truemail
  class Configuration
    DEFAULT_CONNECTION_TIMEOUT = 2
    DEFAULT_RESPONSE_TIMEOUT = 2
    DEFAULT_CONNECTION_ATTEMPTS = 2

    attr_reader :email_pattern,
                :smtp_error_body_pattern,
                :verifier_email,
                :verifier_domain,
                :connection_timeout,
                :response_timeout,
                :connection_attempts,
                :validation_type_by_domain,
                :whitelisted_domains,
                :blacklisted_domains

    attr_accessor :smtp_safe_check

    alias retry_count connection_attempts

    def initialize
      @email_pattern = Truemail::RegexConstant::REGEX_EMAIL_PATTERN
      @smtp_error_body_pattern = Truemail::RegexConstant::REGEX_SMTP_ERROR_BODY_PATTERN
      @connection_timeout = Truemail::Configuration::DEFAULT_CONNECTION_TIMEOUT
      @response_timeout = Truemail::Configuration::DEFAULT_RESPONSE_TIMEOUT
      @connection_attempts = Truemail::Configuration::DEFAULT_CONNECTION_ATTEMPTS
      @validation_type_by_domain = {}
      @whitelisted_domains = []
      @blacklisted_domains = []
      @smtp_safe_check = false
    end

    %i[email_pattern smtp_error_body_pattern].each do |method|
      define_method("#{method}=") do |argument|
        raise_unless(argument, __method__, argument.is_a?(Regexp))
        instance_variable_set(:"@#{method}", argument)
      end
    end

    def verifier_email=(email)
      validate_arguments(email, __method__)
      @verifier_email = email.downcase
      default_verifier_domain
    end

    def verifier_domain=(domain)
      validate_arguments(domain, __method__)
      @verifier_domain = domain.downcase
    end

    %i[connection_timeout response_timeout connection_attempts].each do |method|
      define_method("#{method}=") do |argument|
        raise_unless(argument, __method__, argument.is_a?(Integer) && argument.positive?)
        instance_variable_set(:"@#{method}", argument)
      end
    end

    def validation_type_for=(settings)
      validate_validation_type(settings)
      validation_type_by_domain.merge!(settings)
    end

    %i[whitelisted_domains blacklisted_domains].each do |method|
      define_method("#{method}=") do |argument|
        raise_unless(argument, __method__, argument.is_a?(Array) && check_domain_list(argument))
        instance_variable_set(:"@#{method}", argument)
      end
    end

    def complete?
      !!verifier_email
    end

    private

    def raise_unless(argument_context, argument_name, condition)
      raise Truemail::ArgumentError.new(argument_context, argument_name) unless condition
    end

    def validate_arguments(argument, method)
      constant = Truemail::RegexConstant.const_get("regex_#{method[/\A.+_(.+)\=\z/, 1]}_pattern".upcase)
      raise_unless(argument, method, constant.match?(argument.to_s))
    end

    def default_verifier_domain
      self.verifier_domain ||= verifier_email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3]
    end

    def domain_matcher
      ->(domain) { Truemail::RegexConstant::REGEX_DOMAIN_PATTERN.match?(domain.to_s) }
    end

    def check_domain(domain)
      raise_unless(domain, 'domain', domain_matcher.call(domain))
    end

    def check_domain_list(domains)
      domains.all?(&domain_matcher)
    end

    def check_validation_type(validation_type)
      raise_unless(validation_type, 'validation type', Truemail::Validator::VALIDATION_TYPES.include?(validation_type))
    end

    def validate_validation_type(settings)
      raise_unless(settings, 'hash with settings', settings.is_a?(Hash))
      settings.each do |domain, validation_type|
        check_domain(domain)
        check_validation_type(validation_type)
      end
    end
  end
end
