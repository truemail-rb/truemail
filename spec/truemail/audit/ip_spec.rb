# frozen_string_literal: true

RSpec.describe Truemail::Audit::Ip do
  let(:result_instance) { create_auditor(success: nil, warnings: {}).result }

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:GET_MY_IP_URL) }
    specify { expect(described_class).to be_const_defined(:IPIFY_ERROR) }
  end

  describe 'inheritance' do
    specify { expect(described_class).to be < Truemail::Audit::Base }
  end

  describe '.check' do
    subject(:ip_auditor) { described_class.check(result_instance) }

    let(:chain_of_audit_checks) { :chain_of_audit_checks }
    let(:ip_auditor_instance) { instance_double(described_class, run: chain_of_audit_checks) }

    it 'receive #run' do
      allow(described_class).to receive(:new).and_return(ip_auditor_instance)
      expect(ip_auditor_instance).to receive(:run)
      expect(ip_auditor).to eq(chain_of_audit_checks)
    end
  end

  describe '#run' do
    subject(:ip_auditor) { ip_auditor_instance.run }

    let(:ip_auditor_instance) { described_class.new(result_instance) }

    describe 'Success' do
      context 'when determination of host ip address was successful' do
        let(:host_address) { random_ip_address }

        before { mock_ipify_request(host_address) }

        it 'save host address to result, not changes warnings' do
          expect(Truemail::Audit::Dns).to receive(:check).with(result_instance)
          expect(Truemail::Audit::Ptr).to receive(:check).with(result_instance)
          expect { ip_auditor }
            .to change(result_instance, :current_host_ip)
            .from(nil)
            .to(host_address)
            .and not_change(result_instance, :warnings)
          expect(result_instance.current_host_ip).to match_to_ip_address
        end

        it 'not sensitive to the audit result, runs all possible audit checks' do
          expect(Truemail::Audit::Dns).to receive(:check).with(result_instance).and_return(false)
          expect(Truemail::Audit::Ptr).to receive(:check).with(result_instance)
          ip_auditor
        end
      end
    end

    describe 'Fails' do
      shared_examples 'addes ipify warning to result instance' do
        it 'addes ipify warning to result instance' do
          expectation
          expect(Truemail::Audit::Dns).not_to receive(:check).with(result_instance)
          expect(Truemail::Audit::Ptr).not_to receive(:check).with(result_instance)
          expect { ip_auditor }
            .to change(result_instance, :warnings)
            .from({})
            .to(ip: Truemail::Audit::Ip::IPIFY_ERROR)
            .and change(result_instance, :current_host_ip)
            .from(nil)
            .to(false)
        end
      end

      context 'if error with third party service' do
        let(:expectation) { expect(Truemail::Wrapper).to receive(:call).and_return(false) }

        include_examples 'addes ipify warning to result instance'
      end

      context 'if network error' do
        let(:expectation) { expect(ip_auditor_instance).to receive(:detect_ip_via_ipify).and_raise(::IPAddr::InvalidAddressError) }

        include_examples 'addes ipify warning to result instance'
      end
    end
  end
end
