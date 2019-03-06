module Truemail
  class Configuration
    attr_reader :email_pattern, :verifier_email, :verifier_domain

    REGEX_DOMAIN = /[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,9}/
    REGEX_PATTERN = /(?=\A.{6,255}\z)(\A([\w|-]+)@(#{REGEX_DOMAIN})\z)/
    REGEX_DOMAIN_PATTERN = /\A#{REGEX_DOMAIN}\z/

    def initialize
      @email_pattern = REGEX_PATTERN
    end

    def email_pattern=(regex_pattern)
      raise ArgumentError.new(regex_pattern, Regexp) unless regex_pattern.is_a?(Regexp)
      @email_pattern = regex_pattern
    end

    def verifier_email=(email)
      raise ArgumentError.new(email, 'valid email') unless REGEX_PATTERN.match?(email.to_s)
      @verifier_email = email
      @verifier_domain = email[REGEX_PATTERN, 3]
    end

    def verifier_domain=(domain)
      raise ArgumentError.new(domain, 'valid domain') unless REGEX_DOMAIN_PATTERN.match?(domain.to_s)
      @verifier_domain = domain
    end

    def complete?
      !!verifier_email
    end

    private

    class ArgumentError < StandardError
      def initialize(current_param, class_name)
        super("#{current_param} is not a #{class_name}")
      end
    end
  end
end
