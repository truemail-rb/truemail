# frozen_string_literal: true

RSpec.describe Truemail::Logger do
  subject(:logger_instance) { described_class.new(event, stdout, file) }

  let(:event) { :event }
  let(:stdout) { true }
  let(:file) { nil }

  describe '.new' do
    it 'creates event logger with settings' do
      expect(logger_instance.event).to eq(event)
      expect(logger_instance.stdout).to eq(stdout)
      expect(logger_instance.file).to eq(file)
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

    describe '#create_logs' do
      subject(:create_logs) { logger_instance.send(:create_logs, log_level, serialized_object) }

      let(:log_level) { 1 }
      let(:serialized_object) { 'serialized_object' }
      let(:output_expectation) { "INFO -- : #{serialized_object}" }

      context 'when stdout configured' do
        it 'print to stdout logger info' do
          expect { create_logs }.to output(/#{output_expectation}/).to_stdout
        end
      end

      context 'when output file path configured' do
        let(:stdout) { false }
        let(:file) { Pathname(File.expand_path('../support/tmp/log', File.dirname(__FILE__))) }

        after { FileUtils.rm_rf(file.dirname) }

        context 'when log file not exists' do
          it 'creates file, add log' do
            expect { create_logs }.to change(file, :exist?).from(false).to(true)
            expect(file.read).to include(output_expectation)
          end
        end

        context 'when log file exists' do
          let(:file_context) { 'file_context' }

          before do
            file.parent.mkpath
            File.open(file, 'a+') { |data| data.puts file_context }
          end

          it 'add log to exsiting file context' do
            expect { create_logs }.not_to output(/#{output_expectation}/).to_stdout
            expect(file.read).to include(file_context, output_expectation)
          end
        end
      end
    end
  end
end
