# frozen_string_literal: true

module Truemail
  class Validator < Truemail::Executor
    RESULT_ATTRS = %i[success email domain mail_servers errors smtp_debug configuration].freeze
    VALIDATION_TYPES = %i[regex mx smtp].freeze

    Result = Struct.new(*RESULT_ATTRS, keyword_init: true) do
      def initialize(mail_servers: [], errors: {}, **args)
        super
      end

      def punycode_email
        @punycode_email ||= Truemail::PunycodeRepresenter.call(email)
      end
      alias_method :valid?, :success
    end

    attr_reader :validation_type

    def initialize(email, configuration:, with: nil)
      with ||= configuration.default_validation_type
      raise Truemail::ArgumentError.new(with, :argument) unless Truemail::Validator::VALIDATION_TYPES.include?(with)
      @result = Truemail::Validator::Result.new(email: email, configuration: configuration)
      @validation_type = select_validation_type(email, with)
    end

    def run
      Truemail::Validate::DomainListMatch.check(result)
      result_not_changed? ? Truemail::Validate.const_get(validation_type.capitalize).check(result) : update_validation_type
      logger&.push(self)
      self
    end

    def as_json
      Truemail::Log::Serializer::ValidatorJson.call(self)
    end

    private

    def select_validation_type(email, current_validation_type)
      domain = email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3]
      result.configuration.validation_type_by_domain[domain] || current_validation_type
    end

    def update_validation_type
      @validation_type = result.success ? :whitelist : :blacklist
    end

    def result_status
      result.success
    end

    def result_not_changed?
      result_status.nil?
    end

    def logger
      result.configuration.logger
    end
  end
end
