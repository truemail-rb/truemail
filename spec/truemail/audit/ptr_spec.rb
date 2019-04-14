# frozen_string_literal: true

RSpec.describe Truemail::Audit::Ptr do
  let(:email) { FFaker::Internet.email }
  let(:result_instance) { Truemail::Auditor::Result.new }

  before { Truemail.configure { |config| config.verifier_email = email } }

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:NOT_FOUND) }
    specify { expect(described_class).to be_const_defined(:NOT_REFERENCES) }
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
    let(:host_name) { Truemail.configuration.verifier_domain }
    let(:other_host_name) { 'localhost' }

    before do
      allow(Socket).to receive(:gethostname).and_return(other_host_name)
      allow(Resolv).to receive(:getaddress).and_return(FFaker::Internet.ip_v4_address)
    end

    context 'when ptr record exists and refereces to verifier domain' do
      it 'not changes warnings' do
        expect(Resolv::DNS).to receive_message_chain(:new, :getresources, :map).and_return([host_name])
        expect { ptr_auditor }.to not_change(result_instance, :warnings)
      end
    end

    context 'when ptr record for current host address was not found' do
      it 'addes not found warning' do
        expect(Resolv::DNS).to receive_message_chain(:new, :getresources, :map).and_return([])
        expect { ptr_auditor }.to change(result_instance, :warnings).from({}).to({ ptr: Truemail::Audit::Ptr::NOT_FOUND })
      end
    end

    context 'when ptr record checking crashes' do
      it 'addes not found warning' do
        expect(Resolv::DNS).to receive_message_chain(:new, :getresources, :map).and_raise(Resolv::ResolvError)
        expect { ptr_auditor }.to change(result_instance, :warnings).from({}).to({ ptr: Truemail::Audit::Ptr::NOT_FOUND })
      end
    end

    context 'when ptr record does not reference to current verifier domain' do
      it 'addes not references warning' do
        expect(Resolv::DNS).to receive_message_chain(:new, :getresources, :map).and_return([other_host_name])
        expect { ptr_auditor }.to change(result_instance, :warnings).from({}).to({ ptr: Truemail::Audit::Ptr::NOT_REFERENCES })
      end
    end
  end
end
