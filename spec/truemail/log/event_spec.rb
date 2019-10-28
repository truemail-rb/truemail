# frozen_string_literal: true

RSpec.describe Truemail::Log::Event do
  subject(:event_instance) { described_class.new(event, validator_instance) }

  let(:result_instance) do
    instance_double(
      'Result',
      success: validation_status,
      errors: validation_errors,
      smtp_debug: smtp_debug
    )
  end
  let(:validator_instance) { instance_double('Validator', result: result_instance) }

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:TRACKING_EVENTS) }
  end

  describe '#valid, #log_level' do
    let(:event) { :all }
    let(:validation_status) { true }
    let(:validation_errors) { {} }
    let(:smtp_debug) { nil }

    shared_examples 'untracking action' do
      specify { expect(event_instance.valid?).to be(false) }
    end

    context 'when successful action' do
      specify { expect(event_instance.valid?).to be(true) }
      specify { expect(event_instance.log_level).to eq(1) }

      context 'when current action not exists in tracking event' do
        let(:event) { :error }

        it_behaves_like 'untracking action'
      end
    end

    context 'when unrecognized error action' do
      let(:smtp_debug) { [] }

      specify { expect(event_instance.valid?).to be(true) }
      specify { expect(event_instance.log_level).to eq(2) }

      context 'when current action not exists in tracking event' do
        let(:event) { :recognized_error }

        it_behaves_like 'untracking action'
      end
    end

    context 'when recognized error action' do
      let(:validation_status) { false }
      let(:validation_errors) { { error: :some_error } }

      specify { expect(event_instance.valid?).to be(true) }
      specify { expect(event_instance.log_level).to eq(3) }

      context 'when current action not exists in tracking event' do
        let(:event) { :unrecognized_error }

        it_behaves_like 'untracking action'
      end
    end
  end
end
