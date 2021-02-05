# frozen_string_literal: true

module Truemail
  module Log
    module Serializer
      class ValidatorBase < Truemail::Log::Serializer::Base
        def initialize(executor_instance)
          @validation_type = executor_instance.validation_type
          super
        end

        private

        attr_reader :validation_type

        def replace_invalid_chars
          ->(value) { value.encode('UTF-8', invalid: :replace) }
        end

        def smtp_debug
          validation_smtp_debug = executor_result.smtp_debug
          return unless validation_smtp_debug
          validation_smtp_debug.map do |smtp_request|
            smtp_response = smtp_request.response
            {
              mail_host: smtp_request.host,
              port_opened: smtp_response.port_opened,
              connection: smtp_response.connection,
              errors: smtp_response.errors.transform_values(&replace_invalid_chars)
            }
          end
        end

        def result
          @result ||=
            {
              date: ::Time.now,
              email: executor_result.email,
              validation_type: validation_type,
              success: executor_result.success,
              errors: errors(executor_result.errors),
              smtp_debug: smtp_debug,
              configuration: configuration
            }
        end
      end
    end
  end
end
