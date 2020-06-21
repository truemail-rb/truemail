# frozen_string_literal: true

RSpec.describe Truemail::Audit::Ptr do
  let(:configuration_instance) { create_configuration }
  let(:result_instance) { Truemail::Auditor::Result.new(configuration: configuration_instance) }

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:PTR_NOT_FOUND) }
    specify { expect(described_class).to be_const_defined(:PTR_NOT_REFER) }
  end

  describe 'inheritance' do
    specify { expect(described_class).to be < Truemail::Audit::Base }
  end

  describe '.check' do
    subject(:ptr_auditor) { described_class.check(result_instance) }

    let(:ptr_auditor_instance) { instance_double(described_class, run: true) }

    it 'receive #run' do
      allow(described_class).to receive(:new).and_return(ptr_auditor_instance)
      expect(ptr_auditor_instance).to receive(:run)
      ptr_auditor
    end
  end

  describe '#run' do
    subject(:ptr_auditor) { ptr_auditor_instance.run }

    let(:ptr_auditor_instance) { described_class.new(result_instance) }
    let(:host_name) { configuration_instance.verifier_domain }
    let(:other_host_name) { 'other_host_name' }

    describe 'Success' do
      context 'when ptr record exists and refereces to verifier domain' do
        it 'not changes warnings' do
          allow(ptr_auditor_instance).to receive(:ptr_records).and_return([host_name])
          expect { ptr_auditor }.to not_change(result_instance, :warnings)
        end
      end
    end

    describe 'Fails' do
      context 'when determining ptr records' do
        let(:expectation) do
          expect { ptr_auditor }.to change(result_instance, :warnings).from({}).to(ptr: Truemail::Audit::Ptr::PTR_NOT_FOUND)
        end

        context 'when ptr record checking crashes' do
          it 'addes not found warning' do
            expect(Truemail::Wrapper).to receive(:call).and_return(false)
            expectation
          end
        end

        context 'when ptr record for current host address was not found' do
          it 'addes not found warning' do
            expect(ptr_auditor_instance).to receive(:ptr_records).and_return([])
            expectation
          end
        end
      end

      context 'when determining ptr referer' do
        context 'when ptr records do not refer to verifier domain' do
          it 'addes not references warning' do
            allow(ptr_auditor_instance).to receive(:ptr_records).and_return([other_host_name])
            expect { ptr_auditor }.to change(result_instance, :warnings).from({}).to(ptr: Truemail::Audit::Ptr::PTR_NOT_REFER)
          end
        end
      end
    end
  end
end
