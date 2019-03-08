module Truemail
  class Configuration
    attr_reader :email_pattern, :verifier_email, :verifier_domain

    REGEX_DOMAIN = /[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,9}/
    REGEX_EMAIL_PATTERN = /(?=\A.{6,255}\z)(\A([\w|-]+)@(#{REGEX_DOMAIN})\z)/
    REGEX_DOMAIN_PATTERN = /\A#{REGEX_DOMAIN}\z/

    def initialize
      @email_pattern = REGEX_EMAIL_PATTERN
    end

    def email_pattern=(regex_pattern)
      raise ArgumentError.new(regex_pattern, Regexp) unless regex_pattern.is_a?(Regexp)
      @email_pattern = regex_pattern
    end

    %i[email domain].each do |method|
      define_method(:"verifier_#{method}=") do |argument|
        constant = Configuration.const_get("regex_#{method}_pattern".upcase)
        raise ArgumentError.new(argument, "valid #{method}") unless constant.match?(argument.to_s)
        instance_variable_set(:"@verifier_#{method}", argument)
        default_verifier_domain if method.eql?(:email)
      end
    end

    def complete?
      !!verifier_email
    end

    private

    def default_verifier_domain
      self.verifier_domain ||= verifier_email[REGEX_EMAIL_PATTERN, 3]
    end

    class ArgumentError < StandardError
      def initialize(current_param, class_name)
        super("#{current_param} is not a #{class_name}")
      end
    end
  end
end
