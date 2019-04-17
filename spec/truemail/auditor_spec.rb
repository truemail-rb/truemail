# frozen_string_literal: true

module Truemail
  RSpec.describe Truemail::Auditor do
    subject(:auditor_instance) { described_class.run }

    let(:email) { FFaker::Internet.email }
    let(:auditor_instance_result) { auditor_instance.result }

    before { Truemail.configure { |config| config.verifier_email = email } }

    describe 'defined constants' do
      specify { expect(described_class).to be_const_defined(:Result) }
    end

    describe '.run' do
      it 'creates and updates default auditor result' do
        allow(Truemail::Audit::Ptr).to receive(:check)
        expect(auditor_instance).to be_an_instance_of(Truemail::Auditor)
        expect(auditor_instance_result).to be_an_instance_of(Truemail::Auditor::Result)
        expect(auditor_instance_result.warnings).to eq({})
      end
    end
  end

  RSpec.describe Truemail::Auditor::Result do
    subject(:result_instance) { described_class.new }

    let(:hash_object) { {} }

    specify do
      expect(result_instance.members).to include(:warnings)
    end

    it 'has default values for attributes' do
      expect(result_instance.warnings).to eq(hash_object)
    end

    it 'accepts parametrized arguments' do
      expect(described_class.new(warnings: hash_object).warnings).to eq(hash_object)
    end
  end
end
