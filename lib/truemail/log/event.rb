# frozen_string_literal: true

module Truemail
  module Log
    class Event
      TRACKING_EVENTS =
        {
          all: %i[success unrecognized_error recognized_error],
          unrecognized_error: %i[unrecognized_error],
          recognized_error: %i[recognized_error],
          error: %i[unrecognized_error recognized_error]
        }.freeze

      def initialize(event, validator_instance)
        validator_result = validator_instance.result
        @event = event
        @has_validation_errors = !validator_result.errors.empty?
        @successful_validation = validator_result.success
        @validation_smtp_debug = validator_result.smtp_debug
      end

      def valid?
        Truemail::Log::Event::TRACKING_EVENTS[event].include?(action_level_log.first)
      end

      def log_level
        action_level_log.last
      end

      private

      attr_reader :event, :has_validation_errors, :successful_validation, :validation_smtp_debug

      def action_level_log
        @action_level_log ||=
          case
          when successful_validation && !validation_smtp_debug then [:success, ::Logger::INFO]
          when successful_validation && validation_smtp_debug  then [:unrecognized_error, ::Logger::WARN]
          when !successful_validation && has_validation_errors then [:recognized_error, ::Logger::ERROR]
          end
      end
    end
  end
end
