# frozen_string_literal: true

RSpec.describe Truemail::Logger do
  subject(:logger_instance) { described_class.new(event, stdout, file, custom_logger) }

  let(:event) { :event }
  let(:stdout) { true }
  let(:file) { nil }
  let(:custom_logger) { nil }

  describe '.new' do
    it 'creates event logger with settings' do
      expect(logger_instance.event).to eq(event)
      expect(logger_instance.stdout).to eq(stdout)
      expect(logger_instance.file).to eq(file)
      expect(logger_instance.custom_logger).to be_nil
      expect(logger_instance).to be_an_instance_of(described_class)
    end
  end

  describe '#push' do
    subject(:push_log) { logger_instance.push(validator_instance) }

    let(:validator_instance)  { instance_double('Validator') }
    let(:event_instance)      { instance_double('Event', valid?: event_status, log_level: :log_level) }
    let(:serialized_object)   { :serialized_object }

    context 'when valid event' do
      let(:event_status) { true }

      it 'calls create_logs' do
        expect(Truemail::Log::Event).to receive(:new).with(logger_instance.event, validator_instance).and_return(event_instance)
        expect(Truemail::Log::Serializer::ValidatorText).to receive(:call).with(validator_instance).and_return(serialized_object)
        expect(logger_instance).to receive(:create_logs).with(event_instance.log_level, serialized_object)
        push_log
      end
    end

    context 'when invalid event' do
      let(:event_status) { false }

      it 'not calls create_logs' do
        expect(Truemail::Log::Event).to receive(:new).with(logger_instance.event, validator_instance).and_return(event_instance)
        expect(logger_instance).not_to receive(:create_logs).with(event_instance.log_level, serialized_object)
        push_log
      end
    end
  end

  describe '#create_logs' do
    subject(:create_logs) { logger_instance.send(:create_logs, log_level, serialized_object) }

    let(:log_level) { 1 }
    let(:serialized_object) { 'serialized_object' }
    let(:output_expectation) { "INFO -- : #{serialized_object}" }
    let(:custom_logger_instnace) { instance_double('SomeCustomLoggerInstance') }

    context 'when stdout configured' do
      it 'print to stdout logger info' do
        expect(custom_logger_instnace)
          .not_to receive(:add)
          .with(log_level) { |&block| expect(block.call).to eq(serialized_object) }
        expect { create_logs }.to output(/#{output_expectation}/).to_stdout
      end
    end

    context 'when output file path configured' do
      let(:stdout) { false }
      let(:file) { Pathname(::File.expand_path('../support/tmp/log', ::File.dirname(__FILE__))) }

      after { ::FileUtils.rm_rf(file.dirname) }

      context 'when log file not exists' do
        it 'creates file, add log' do
          expect(custom_logger_instnace)
            .not_to receive(:add)
            .with(log_level) { |&block| expect(block.call).to eq(serialized_object) }
          expect { create_logs }.to change(file, :exist?).from(false).to(true)
          expect(file.read).to include(output_expectation)
        end
      end

      context 'when log file exists' do
        let(:file_context) { 'file_context' }

        before do
          file.parent.mkpath
          ::File.open(file, 'a+') { |data| data.puts file_context }
        end

        it 'add log to exsiting file context' do
          expect { create_logs }.not_to output(/#{output_expectation}/).to_stdout
          expect(file.read).to include(file_context, output_expectation)
        end
      end
    end

    context 'when custom logger instance configured' do
      let(:custom_logger) { custom_logger_instnace }

      it 'sends truemail log context to custom logger instance' do
        expect(custom_logger_instnace)
          .to receive(:add)
          .with(log_level) { |&block| expect(block.call).to eq(serialized_object) }
        create_logs
      end
    end
  end
end

RSpec.describe Truemail::Logger::Builder do
  specify { expect(described_class).to be < ::Struct }

  describe '.call' do
    subject(:build_logger_instance) { described_class.call(default_settings, **logger_attributes) }

    let(:default_settings) { {} }
    let(:custom_logger) { nil }
    let(:logger_attributes) do
      {
        tracking_event: tracking_event,
        stdout: stdout,
        log_absolute_path: log_absolute_path,
        custom_logger: custom_logger
      }
    end

    context 'when valid logger attributes' do
      let(:tracking_event) { Truemail::Log::Event::TRACKING_EVENTS.keys.sample }

      context 'when custom logger instance' do
        let(:custom_logger) { instance_double('SomeCustomLoggerInstance', add: 42) }
        let(:stdout) { nil }
        let(:log_absolute_path) { nil }

        it 'builds truemail logger instance using custom logger instance' do
          expect(Truemail::Logger)
            .to receive(:new)
            .with(tracking_event, stdout, log_absolute_path, custom_logger)
          build_logger_instance
        end
      end

      context 'when stdout output passed' do
        let(:stdout) { true }
        let(:log_absolute_path) { nil }

        it 'builds truemail logger instance with default logger targeted to stdout' do
          expect(Truemail::Logger)
            .to receive(:new)
            .with(tracking_event, stdout, log_absolute_path, custom_logger)
          build_logger_instance
        end
      end

      context 'when file output passed' do
        let(:stdout) { false }
        let(:log_absolute_path) { 'some_absolute_path' }

        it 'builds truemail logger instance with default logger targeted to file' do
          expect(Truemail::Logger)
            .to receive(:new)
            .with(tracking_event, stdout, log_absolute_path, custom_logger)
          build_logger_instance
        end
      end

      context 'when both stdout and file output passed' do
        let(:stdout) { true }
        let(:log_absolute_path) { 'some_absolute_path' }

        it 'builds truemail logger instance with default logger targeted to stdout and file' do
          expect(Truemail::Logger)
            .to receive(:new)
            .with(tracking_event, stdout, log_absolute_path, custom_logger)
          build_logger_instance
        end
      end
    end

    context 'when invalid logger attributes' do
      let(:tracking_event) { Truemail::Log::Event::TRACKING_EVENTS.keys.sample }

      shared_examples 'raises truemail argument error' do
        specify 'raises truemail argument error' do
          expect(Truemail::Logger)
            .not_to receive(:new)
            .with(tracking_event, stdout, log_absolute_path, custom_logger)
          expect { build_logger_instance }.to raise_error(
            Truemail::ArgumentError,
            error_context
          )
        end
      end

      context 'when wrong tracking event name' do
        let(:tracking_event) { 'wrong_tracking_event' }
        let(:stdout) { nil }
        let(:log_absolute_path) { nil }
        let(:error_context) { "#{tracking_event} is not a valid tracking_event=" }

        include_examples 'raises truemail argument error'
      end

      context 'when builtin logger output did not specified' do
        let(:stdout) { nil }
        let(:log_absolute_path) { nil }
        let(:error_context) { '{:stdout=>nil, :log_absolute_path=>nil} is not a valid stdout=, log_absolute_path=' }

        include_examples 'raises truemail argument error'
      end

      context 'when the custom logger instance has a different than stdlib logger interface' do
        let(:custom_logger) { instance_double('SomeCustomLoggerInstance') }
        let(:stdout) { nil }
        let(:log_absolute_path) { nil }
        let(:error_context) { "#{custom_logger} is not a valid custom_logger=" }

        include_examples 'raises truemail argument error'
      end
    end
  end
end
