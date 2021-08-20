# frozen_string_literal: true

RSpec.describe Truemail::Audit::Dns do
  let(:configuration_instance) { create_configuration(dns: dns_mock_gateway) }
  let(:verifier_domain) { configuration_instance.verifier_domain }
  let(:current_host_ip) { random_ip_address }
  let(:result_instance) { create_auditor(current_host_ip: current_host_ip, configuration: configuration_instance).result }

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
        before { dns_mock_server.assign_mocks(verifier_domain => { a: [current_host_ip] }) }

        it 'not changes warnings' do
          expect { dns_auditor }.to not_change(result_instance, :warnings)
          dns_auditor
        end
      end
    end

    describe 'Fails' do
      shared_examples 'addes verifier domain not refer warning to result instance' do
        it 'addes verifier domain not refer warning to result instance' do
          expect { dns_auditor }
            .to change(result_instance, :warnings)
            .from({}).to(dns: Truemail::Audit::Dns::VERIFIER_DOMAIN_NOT_REFER)
          dns_auditor
        end
      end

      context 'when verifier domain not found' do
        include_examples 'addes verifier domain not refer warning to result instance'
      end

      context 'when a record of verifier domain not refers to currernt host ip address' do
        before { dns_mock_server.assign_mocks(verifier_domain => { a: [random_ip_address] }) }

        include_examples 'addes verifier domain not refer warning to result instance'
      end
    end
  end
end
