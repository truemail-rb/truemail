# frozen_string_literal: true

module Truemail
  RSpec.describe ConfigurationHelper, type: :helper do
    describe '#configuration_block' do
      let(:configuration_params) { { param_1: 1, param_2: 2 } }
      let(:configuration_instance) { Struct.new(*configuration_params.keys).new }

      before { configuration_block(configuration_params).call(configuration_instance) }

      specify { expect(configuration_block).to be_an_instance_of(Proc) }

      it 'sets configuration instance attributes' do
        configuration_params.each do |attribute, value|
          expect(configuration_instance.public_send(attribute)).to eq(value)
        end
      end
    end

    describe '#create_configuration' do
      subject(:configuration_builder) { create_configuration(params) }

      let(:params) { {} }

      context 'with default params' do
        it 'returns configuration instance with random verifier email' do
          expect(configuration_builder).to be_an_instance_of(Truemail::Configuration)
          expect(configuration_builder.verifier_email).not_to be_nil
        end
      end

      context 'with custom params' do
        let(:verifier_email) { FFaker::Internet.email }
        let(:params) { { verifier_email: verifier_email } }

        it 'returns configuration instance with custom verifier email' do
          expect(configuration_builder).to be_an_instance_of(Truemail::Configuration)
          expect(configuration_builder.verifier_email).to eq(verifier_email)
        end
      end
    end
  end
end
