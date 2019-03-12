module Truemail
  class Validator
    RESULT_ATTRS = %i[success email domain mail_servers errors smtp_debug].freeze
    VALIDATION_TYPES = %i[regex mx smtp].freeze

    Result = Struct.new(*RESULT_ATTRS, keyword_init: true) do
      def initialize(errors: {}, mail_servers: [], **args)
        super
      end
      alias_method :valid?, :success
    end

    attr_reader :validation_type, :result

    def initialize(email, with: :smtp)
      raise ArgumentError.new(with, :argument) unless VALIDATION_TYPES.include?(with)
      @validation_type, @result = with, Result.new(email: email)
    end

    def run
      Truemail::Validate.const_get(validation_type.capitalize).check(result)
      self
    end
  end
end
