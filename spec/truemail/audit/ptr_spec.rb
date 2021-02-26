# frozen_string_literal: true

RSpec.describe Truemail::Audit::Ptr do
  let(:configuration_instance) { create_configuration(dns: ["127.0.0.1:#{dns_mock_server.port}"]) }
  let(:verifier_domain) { configuration_instance.verifier_domain }
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
    let(:current_host_ip) { random_ip_address }

    before { allow(ptr_auditor_instance).to receive(:current_host_ip).and_return(current_host_ip) }

    describe 'Success' do
      context 'when ptr record exists and refereces to verifier domain' do
        before { dns_mock_server.assign_mocks(current_host_ip => { ptr: [verifier_domain] }) }

        it 'not changes warnings' do
          expect { ptr_auditor }.to not_change(result_instance, :warnings)
        end
      end
    end

    describe 'Fails' do
      shared_examples 'addes warning context into result instance' do
        it 'addes warning context into result instance' do
          expect { ptr_auditor }
            .to change(result_instance, :warnings)
            .from({})
            .to(ptr: warning_context)
        end
      end

      context 'when determining ptr records' do
        context 'when ptr record checking crashes' do
          let(:warning_context) { Truemail::Audit::Ptr::PTR_NOT_FOUND }

          before { allow(Truemail::Dns::Resolver).to receive(:ptr_records).and_raise(::Resolv::ResolvError) }

          include_examples 'addes warning context into result instance'
        end

        context 'when ptr record for current host address was not found' do
          let(:warning_context) { Truemail::Audit::Ptr::PTR_NOT_FOUND }

          include_examples 'addes warning context into result instance'
        end
      end

      context 'when determining ptr referer' do
        context 'when ptr records do not refer to verifier domain' do
          let(:warning_context) { Truemail::Audit::Ptr::PTR_NOT_REFER }

          before { dns_mock_server.assign_mocks(current_host_ip => { ptr: [random_domain_name] }) }

          include_examples 'addes warning context into result instance'
        end
      end
    end
  end
end
