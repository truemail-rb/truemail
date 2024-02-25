# frozen_string_literal: true

module Truemail
  class Logger
    require 'logger'

    BUILDER_ATTRS = %i[tracking_event stdout log_absolute_path custom_logger].freeze

    Builder = ::Struct.new(*BUILDER_ATTRS, keyword_init: true) do
      private_class_method :new

      def self.call(default_settings, **logger_attributes)
        new(default_settings, **logger_attributes).validate_attributes.build_instance
      end

      def initialize(default_settings, **args)
        super(**default_settings.merge(**args))
      end

      def validate_attributes
        validate_logger_event
        return validate_logger_instance if custom_logger
        validate_logger_output
        self
      end

      def build_instance
        Truemail::Logger.new(tracking_event, stdout, log_absolute_path, custom_logger)
      end

      private

      def raise_unless(argument_context, argument_name, condition)
        raise Truemail::ArgumentError.new(argument_context, argument_name) unless condition
      end

      def validate_logger_instance
        raise_unless(custom_logger, :custom_logger=, custom_logger && custom_logger.respond_to?(:add))
        self
      end

      def validate_logger_event
        raise_unless(tracking_event, :tracking_event=, Truemail::Log::Event::TRACKING_EVENTS.key?(tracking_event))
      end

      def validate_logger_output
        stdout_only = stdout && log_absolute_path.nil?
        file_only = log_absolute_path.is_a?(::String)
        both_types = stdout && file_only
        raise_unless(
          { stdout: stdout, log_absolute_path: log_absolute_path },
          'stdout=, log_absolute_path=',
          both_types || stdout_only || file_only
        )
      end
    end

    attr_reader :event, :stdout, :file, :custom_logger, :stdout_logger, :file_logger

    def initialize(event, error_stdout, log_absolute_path, custom_logger)
      @event = event
      @stdout = error_stdout
      @file = log_absolute_path
      @custom_logger = custom_logger
      init_builtin_loggers
    end

    def push(validator_instance)
      current_event = Truemail::Log::Event.new(event, validator_instance)
      return unless current_event.valid?
      create_logs(current_event.log_level, Truemail::Log::Serializer::ValidatorText.call(validator_instance))
    end

    private

    def init_log_file
      output_file = Pathname(file)
      return output_file if output_file.exist?
      output_file.parent.mkpath && ::FileUtils.touch(output_file)
      output_file
    end

    def init_builtin_loggers
      return if custom_logger
      %i[stdout file].each do |output_type|
        next unless public_send(output_type)
        instance_variable_set(
          :"@#{output_type}_logger",
          ::Logger.new(output_type.eql?(:stdout) ? $stdout : init_log_file)
        )
      end
    end

    def create_logs(log_level, serialized_object)
      %i[custom_logger stdout_logger file_logger].each do |getter|
        logger_instance = public_send(getter)
        next unless logger_instance
        logger_instance.add(log_level) { serialized_object }
      end
    end
  end
end
