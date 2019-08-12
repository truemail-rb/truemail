# frozen_string_literal: true

module Truemail
  RSpec.describe Truemail::Auditor do
    subject(:auditor_instance) { described_class.new(configuration: configuration_instance) }

    let(:configuration_instance) { create_configuration }

    describe 'defined constants' do
      specify { expect(described_class).to be_const_defined(:Result) }
    end

    describe '.new' do
      it 'creates auditor with result getter' do
        expect(auditor_instance.result).to be_an_instance_of(Truemail::Auditor::Result)
      end
    end

    describe '#run' do
      it 'runs audition methods' do
        expect(Truemail::Audit::Ptr).to receive(:check)
        expect(auditor_instance.run).to be_an_instance_of(described_class)
      end
    end
  end

  RSpec.describe Truemail::Auditor::Result do
    subject(:result_instance) { described_class.new }

    it 'has attribute accessors warnings, configuration' do
      expect(result_instance.members).to include(:warnings, :configuration)
    end

    it 'has default values for attributes' do
      expect(result_instance.warnings).to eq({})
    end

    it 'accepts parametrized arguments' do
      expect(described_class.new(warnings: :data).warnings).to eq(:data)
    end
  end
end
