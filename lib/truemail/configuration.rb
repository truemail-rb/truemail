# frozen_string_literal: true

module Truemail
  class Configuration
    DEFAULT_CONNECTION_TIMEOUT = 2
    DEFAULT_RESPONSE_TIMEOUT = 2
    DEFAULT_RETRY_COUNT = 1

    attr_reader :email_pattern,
                :verifier_email,
                :verifier_domain,
                :connection_timeout,
                :response_timeout,
                :retry_count,
                :validation_type_by_domain

    attr_accessor :smtp_safe_check

    def initialize
      @email_pattern = Truemail::RegexConstant::REGEX_EMAIL_PATTERN
      @connection_timeout = Truemail::Configuration::DEFAULT_CONNECTION_TIMEOUT
      @response_timeout = Truemail::Configuration::DEFAULT_RESPONSE_TIMEOUT
      @retry_count = Truemail::Configuration::DEFAULT_RETRY_COUNT
      @validation_type_by_domain = {}
      @smtp_safe_check = false
    end

    def email_pattern=(regex_pattern)
      raise Truemail::ArgumentError.new(regex_pattern, Regexp) unless regex_pattern.is_a?(Regexp)
      @email_pattern = regex_pattern
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

    %i[connection_timeout response_timeout retry_count].each do |method|
      define_method("#{method}=") do |argument|
        raise ArgumentError.new(argument, __method__) unless argument.is_a?(Integer) && argument.positive?
        instance_variable_set(:"@#{method}", argument)
      end
    end

    def validation_type_for=(settings)
      validate_validation_type(settings)
      validation_type_by_domain.merge!(settings)
    end

    def complete?
      !!verifier_email
    end

    private

    def validate_arguments(argument, method)
      constant = Truemail::RegexConstant.const_get("regex_#{method[/\A.+_(.+)\=\z/, 1]}_pattern".upcase)
      raise Truemail::ArgumentError.new(argument, method) unless constant.match?(argument.to_s)
    end

    def default_verifier_domain
      self.verifier_domain ||= verifier_email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3]
    end

    def check_domain(domain)
      raise Truemail::ArgumentError.new(domain, 'domain') unless
        Truemail::RegexConstant::REGEX_DOMAIN_PATTERN.match?(domain.to_s)
    end

    def check_validation_type(validation_type)
      raise Truemail::ArgumentError.new(validation_type, 'validation type') unless
          Truemail::Validator::VALIDATION_TYPES.include?(validation_type)
    end

    def validate_validation_type(settings)
      settings.each do |domain, validation_type|
        check_domain(domain)
        check_validation_type(validation_type)
      end
    end
  end
end
