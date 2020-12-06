# frozen_string_literal: true

RSpec.describe Truemail::Validate::Regex do
  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:ERROR) }
  end

  describe 'inheritance' do
    specify { expect(described_class).to be < Truemail::Validate::Base }
  end

  describe '.check' do
    subject(:regex_validator) { described_class.check(result_instance) }

    let(:configuration_instance) { create_configuration }
    let(:result_instance) do
      Truemail::Validator::Result.new(email: Faker::Internet.email, configuration: configuration_instance)
    end

    context 'when validation pass' do
      before do
        allow(configuration_instance).to receive_message_chain(:email_pattern, :match?).and_return(true)
      end

      specify do
        expect { regex_validator }.to change(result_instance, :success).from(nil).to(true)
      end

      it 'returns true' do
        expect(regex_validator).to be(true)
      end
    end

    context 'when validation fails' do
      before do
        allow(configuration_instance).to receive_message_chain(:email_pattern, :match?).and_return(false)
      end

      specify do
        expect { regex_validator }
          .to change(result_instance, :success)
          .from(nil).to(false)
          .and change(result_instance, :errors)
          .from({}).to(regex: Truemail::Validate::Regex::ERROR)
      end

      it 'returns false' do
        expect(regex_validator).to be(false)
      end
    end
  end
end
