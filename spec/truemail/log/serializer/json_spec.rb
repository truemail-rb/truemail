# frozen_string_literal: true

RSpec.describe Truemail::Log::Serializer::Json do
  describe '.call' do
    subject(:json_serializer) { described_class.call(validator_instance) }

    let(:validator_instance) { create_validator(validation_type, success: success_status) }

    shared_context 'serialized json' do
      %i[whitelist regex mx smtp].each do |validation_layer_name|
        describe "#{validation_layer_name} validation" do
          let(:validation_type) { validation_layer_name }

          it 'returns serialized json' do
            expect(json_serializer).to match_json_schema('validator')
          end
        end
      end
    end

    context 'with successful validation result' do
      let(:success_status)  { true }

      include_context 'serialized json'
    end

    context 'with fail validation result' do
      let(:success_status)  { false }

      include_context 'serialized json'
    end
  end
end
