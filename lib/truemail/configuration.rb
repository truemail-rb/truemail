# frozen_string_literal: true

module Truemail
  class Configuration
    DEFAULT_CONNECTION_TIMEOUT = 2
    DEFAULT_RESPONSE_TIMEOUT = 2
    DEFAULT_CONNECTION_ATTEMPTS = 2
    DEFAULT_VALIDATION_TYPE = :smtp
    DEFAULT_LOGGER_OPTIONS = { tracking_event: :error, stdout: false, log_absolute_path: nil }.freeze
    SETTERS = %i[
      email_pattern
      smtp_error_body_pattern
      connection_timeout
      response_timeout
      connection_attempts
      whitelisted_domains
      blacklisted_domains
    ].freeze

    attr_reader :verifier_email,
                :verifier_domain,
                :default_validation_type,
                :validation_type_by_domain,
                :dns,
                :logger,
                *Truemail::Configuration::SETTERS

    attr_accessor :whitelist_validation, :not_rfc_mx_lookup_flow, :smtp_fail_fast, :smtp_safe_check

    def initialize(&block)
      instance_initializer.each do |instace_variable, value|
        instance_variable_set(:"@#{instace_variable}", value)
      end
      tap(&block) if block
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

    def default_validation_type=(argument)
      raise_unless(argument, __method__, argument.is_a?(::Symbol) && Truemail::Validator::VALIDATION_TYPES.include?(argument))
      @default_validation_type = argument
    end

    def validation_type_for=(settings)
      validate_validation_type(settings)
      validation_type_by_domain.merge!(settings)
    end

    def argument_consistent?(argument)
      case argument
      when ::Array then check_domain_list(argument)
      when ::Integer then argument.positive?
      when ::Regexp then true
      end
    end

    Truemail::Configuration::SETTERS.each do |method|
      define_method("#{method}=") do |argument|
        raise_unless(argument, __method__, argument_consistent?(argument))
        instance_variable_set(:"@#{method}", argument)
      end
    end

    def dns=(argument)
      raise_unless(argument, __method__, argument.is_a?(::Array) && check_dns_settings(argument))
      @dns = argument
    end

    def logger=(options)
      tracking_event, stdout, log_absolute_path = logger_options(options)
      valid_event = Truemail::Log::Event::TRACKING_EVENTS.key?(tracking_event)
      stdout_only = stdout && log_absolute_path.nil?
      file_only = log_absolute_path.is_a?(::String)
      both_types = stdout && file_only
      argument_info = valid_event ? log_absolute_path : tracking_event
      raise_unless(argument_info, __method__, valid_event && (stdout_only || file_only || both_types))
      @logger = Truemail::Logger.new(tracking_event, stdout, log_absolute_path)
    end

    def complete?
      !!verifier_email
    end

    private

    def instance_initializer # rubocop:disable Metrics/MethodLength
      {
        email_pattern: Truemail::RegexConstant::REGEX_EMAIL_PATTERN,
        smtp_error_body_pattern: Truemail::RegexConstant::REGEX_SMTP_ERROR_BODY_PATTERN,
        connection_timeout: Truemail::Configuration::DEFAULT_CONNECTION_TIMEOUT,
        response_timeout: Truemail::Configuration::DEFAULT_RESPONSE_TIMEOUT,
        connection_attempts: Truemail::Configuration::DEFAULT_CONNECTION_ATTEMPTS,
        default_validation_type: Truemail::Configuration::DEFAULT_VALIDATION_TYPE,
        validation_type_by_domain: {},
        whitelisted_domains: [],
        whitelist_validation: false,
        blacklisted_domains: [],
        dns: [],
        not_rfc_mx_lookup_flow: false,
        smtp_fail_fast: false,
        smtp_safe_check: false
      }
    end

    def raise_unless(argument_context, argument_name, condition)
      raise Truemail::ArgumentError.new(argument_context, argument_name) unless condition
    end

    def validate_arguments(argument, method)
      constant = Truemail::RegexConstant.const_get("regex_#{method[/\A.+_(.+)=\z/, 1]}_pattern".upcase)
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
      raise_unless(settings, 'hash with settings', settings.is_a?(::Hash))
      settings.each do |domain, validation_type|
        check_domain(domain)
        check_validation_type(validation_type)
      end
    end

    def dns_server_matcher
      ->(dns_server) { Truemail::RegexConstant::REGEX_DNS_SERVER_ADDRESS_PATTERN.match?(dns_server.to_s) }
    end

    def check_dns_settings(dns_servers)
      dns_servers.all?(&dns_server_matcher)
    end

    def logger_options(current_options)
      Truemail::Configuration::DEFAULT_LOGGER_OPTIONS.merge(current_options).values
    end
  end
end
