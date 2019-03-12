module Truemail
  class Configuration
    DEFAULT_CONNECTION_TIMEOUT = 2
    DEFAULT_RESPONSE_TIMEOUT = 2

    attr_reader :email_pattern,
                :verifier_email,
                :verifier_domain,
                :connection_timeout,
                :response_timeout

    def initialize
      @email_pattern = Truemail::RegexConstant::REGEX_EMAIL_PATTERN
      @connection_timeout = DEFAULT_CONNECTION_TIMEOUT
      @response_timeout = DEFAULT_RESPONSE_TIMEOUT
    end

    def email_pattern=(regex_pattern)
      raise Truemail::ArgumentError.new(regex_pattern, Regexp) unless regex_pattern.is_a?(Regexp)
      @email_pattern = regex_pattern
    end

    def verifier_email=(email)
      validate_arguments(email, __method__)
      @verifier_email = email
      default_verifier_domain
    end

    def verifier_domain=(domain)
      validate_arguments(domain, __method__)
      @verifier_domain = domain
    end

    %i[connection_timeout response_timeout].each do |method|
      define_method("#{method}=") do |argument|
        raise ArgumentError.new(argument, __method__) unless argument.is_a?(Integer) && argument.positive?
        instance_variable_set(:"@#{method}", argument)
      end
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
  end
end
