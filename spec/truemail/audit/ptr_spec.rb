# frozen_string_literal: true

RSpec.describe Truemail::Audit::Ptr do
  let(:configuration_instance) { create_configuration }
  let(:result_instance) { Truemail::Auditor::Result.new(configuration: configuration_instance) }

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:GET_MY_IP_URL) }
    specify { expect(described_class).to be_const_defined(:IPIFY_ERROR) }
    specify { expect(described_class).to be_const_defined(:PTR_NOT_FOUND) }
    specify { expect(described_class).to be_const_defined(:PTR_NOT_REFER) }
    specify { expect(described_class).to be_const_defined(:VERIFIER_DOMAIN_NOT_REFER) }
  end

  describe '.check' do
    subject(:ptr_auditor) { described_class.check(result_instance) }

    let(:ptr_auditor_instance) { instance_double(described_class, run: true) }

    it 'receive #run' do
      allow(described_class).to receive(:new).and_return(ptr_auditor_instance)
      expect(ptr_auditor_instance).to receive(:run)
      expect(ptr_auditor).to be(true)
    end
  end

  describe '#run' do
    subject(:ptr_auditor) { ptr_auditor_instance.run }

    let(:ptr_auditor_instance) { described_class.new(result_instance) }
    let(:host_name) { configuration_instance.verifier_domain }
    let(:host_address) { FFaker::Internet.ip_v4_address }
    let(:other_host_address) { '127.0.0.1' }

    describe 'Success' do
      context 'when ptr record exists, refereces to verifier domain and has reverse trace' do
        before do
          allow(ptr_auditor_instance).to receive(:detect_ip_via_ipify).and_return(host_address)
          allow(ptr_auditor_instance).to receive(:ptr_records).and_return([host_name])
          allow(ptr_auditor_instance).to receive(:a_record).and_return(host_address)
        end

        it 'not changes warnings' do
          expect { ptr_auditor }.to not_change(result_instance, :warnings)
        end
      end
    end

    describe 'Fails' do
      context 'when determining current host address' do
        let(:expectation) do
          expect { ptr_auditor }.to change(result_instance, :warnings).from({}).to(ptr: Truemail::Audit::Ptr::IPIFY_ERROR)
        end

        context 'if error with third party service' do
          it 'addes ipify warning' do
            expect(ptr_auditor_instance).to receive(:current_host_address).and_return(false)
            expectation
          end
        end

        context 'if network error' do
          it 'addes ipify warning' do
            expect(ptr_auditor_instance).to receive(:detect_ip_via_ipify).and_raise(IPAddr::InvalidAddressError)
            expectation
          end
        end
      end

      context 'when determining ptr records' do
        let(:expectation) do
          expect { ptr_auditor }.to change(result_instance, :warnings).from({}).to(ptr: Truemail::Audit::Ptr::PTR_NOT_FOUND)
        end

        context 'if ptr record for current host address was not found' do
          it 'addes not found warning' do
            expect(ptr_auditor_instance).to receive(:current_host_address).and_return(true)
            expect(ptr_auditor_instance).to receive(:ptr_records).and_return([])
            expectation
          end
        end

        context 'if ptr record checking crashes' do
          it 'addes not found warning' do
            expect(ptr_auditor_instance).to receive(:current_host_address).and_return(true)
            expect(ptr_auditor_instance).to receive(:current_host_reverse_lookup).and_raise(Resolv::ResolvError)
            expectation
          end
        end
      end

      context 'when determining ptr referer' do
        context 'if ptr records do not refer to verifier domain' do
          it 'addes not references warning' do
            expect(ptr_auditor_instance).to receive(:current_host_address).and_return(true)
            expect(ptr_auditor_instance).to receive(:ptr_records).and_return([host_name])
            expect(ptr_auditor_instance).to receive(:ptr_not_refer_to_verifier_domain?).and_return(true)
            expect { ptr_auditor }.to change(result_instance, :warnings).from({}).to(ptr: Truemail::Audit::Ptr::PTR_NOT_REFER)
          end
        end
      end

      context 'when determining verifier domain referer' do
        let(:expectation) do
          expect { ptr_auditor }
            .to change(result_instance, :warnings)
            .from({}).to(ptr: Truemail::Audit::Ptr::VERIFIER_DOMAIN_NOT_REFER)
        end

        before do
          allow(ptr_auditor_instance).to receive(:detect_ip_via_ipify).and_return(host_address)
          allow(ptr_auditor_instance).to receive(:ptr_records).and_return([host_name])
          allow(ptr_auditor_instance).to receive(:ptr_not_refer_to_verifier_domain?).and_return(false)
        end

        context 'if verifier domain a record does not refer to ptr record' do
          it 'addes not reverse trace warning' do
            expect(ptr_auditor_instance).to receive(:a_record).and_return(other_host_address)
            expectation
          end
        end

        context 'if network error' do
          it 'addes not reverse trace warning' do
            expect(Resolv::DNS).to receive_message_chain(:new, :getaddress, :to_s).and_raise(Resolv::ResolvError)
            expectation
          end
        end
      end
    end
  end

  describe 'ipify third party service integration tests' do
    context 'when calles #detect_ip_via_ipify' do
      subject(:ipify_response) { ptr_auditor_instance.send(:detect_ip_via_ipify) }

      let(:ptr_auditor_instance) { described_class.new(result_instance) }

      it 'returns current host ip address as a string' do
        expect(ipify_response).to be_an_instance_of(String)
      end

      it 'returned string matches to ip address pattern' do
        expect(ipify_response).to match_to_ip_address
      end
    end
  end
end
