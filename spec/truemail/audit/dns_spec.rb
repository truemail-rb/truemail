# frozen_string_literal: true

RSpec.describe Truemail::Audit::Dns do
  let(:configuration_instance) { create_configuration }
  let(:result_instance) { Truemail::Auditor::Result.new(configuration: configuration_instance) }

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:VERIFIER_DOMAIN_NOT_REFER) }
  end

  describe 'inheritance' do
    specify { expect(described_class).to be < Truemail::Audit::Base }
  end

  describe '.check' do
    subject(:dns_auditor) { described_class.check(result_instance) }

    let(:dns_auditor_instance) { instance_double(described_class) }

    it 'receive #run' do
      allow(described_class).to receive(:new).and_return(dns_auditor_instance)
      expect(dns_auditor_instance).to receive(:run)
      dns_auditor
    end
  end

  describe '#run' do
    subject(:dns_auditor) { dns_auditor_instance.run }

    let(:dns_auditor_instance) { described_class.new(result_instance) }

    describe 'Success' do
      context 'when a record found and refers to current host ip' do
        it 'not changes warnings' do
          allow(dns_auditor_instance).to receive(:verifier_domain_refer_to_current_host_ip?).and_return(true)
          expect { dns_auditor }.to not_change(result_instance, :warnings)
          dns_auditor
        end
      end
    end

    describe 'Fails' do
      shared_examples 'addes verifier domain not refer warning to result instance' do
        it 'addes verifier domain not refer warning to result instance' do
          expectation
          expect { dns_auditor }
            .to change(result_instance, :warnings)
            .from({}).to(dns: Truemail::Audit::Dns::VERIFIER_DOMAIN_NOT_REFER)
          dns_auditor
        end
      end

      context 'when verifier domain not found' do
        let(:expectation) { allow(dns_auditor_instance).to receive(:a_record).and_return(false) }

        include_examples 'addes verifier domain not refer warning to result instance'
      end

      context 'when a record of verifier domain not refers to currernt host ip address' do
        let(:expectation) do
          allow(dns_auditor_instance).to receive(:verifier_domain_refer_to_current_host_ip?).and_return(false)
        end

        include_examples 'addes verifier domain not refer warning to result instance'
      end
    end
  end
end
