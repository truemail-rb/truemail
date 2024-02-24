# frozen_string_literal: true

module Truemail
  class Logger
    attr_reader :logger_class, :event, :stdout, :file

    def initialize(logger_class, event, error_stdout, log_absolute_path)
      @logger_class = logger_class
      @event = event
      @stdout = error_stdout
      @file = log_absolute_path
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

    def create_logs(log_level, serialized_object)
      %i[stdout file].each do |output_type|
        next unless public_send(output_type)
        logger_class.new(output_type.eql?(:stdout) ? $stdout : init_log_file).add(log_level) { serialized_object }
      end
    end
  end
end
