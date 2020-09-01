# frozen_string_literal: true

RSpec.describe Truemail::Log::Serializer::AuditorJson do
  describe 'inheritance' do
    specify { expect(described_class).to be < Truemail::Log::Serializer::Base }
  end

  describe '.call' do
    subject(:json_serializer) { described_class.call(auditor_instance) }

    let(:auditor_instance) { create_auditor(success: success_status, configuration: create_configuration) }

    shared_examples 'serialized json' do
      it 'returns serialized json' do
        expect(json_serializer).to match_json_schema('auditor')
      end
    end

    context 'without warnings in result' do
      let(:success_status) { true }

      include_examples 'serialized json'
    end

    context 'with warnings in result' do
      let(:success_status) { false }

      include_examples 'serialized json'
    end
  end
end
