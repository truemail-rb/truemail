# frozen_string_literal: true

RSpec.describe Truemail::Validate::MxBlacklist do
  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:ERROR) }
  end

  describe 'inheritance' do
    specify { expect(described_class).to be < Truemail::Validate::Base }
  end

  describe '.check' do
    subject(:mx_blacklist_validator) { described_class.check(result_instance) }

    let(:result_instance) { instance_double('ValidatorInstanceResult') }
    let(:mx_blacklist_validator_instance) { instance_double(described_class, run: true) }

    it 'receive #run' do
      allow(Truemail::Validate::Mx).to receive(:check).and_return(true)
      expect(described_class).to receive(:new).and_return(mx_blacklist_validator_instance)
      expect(mx_blacklist_validator_instance).to receive(:run)
      expect(mx_blacklist_validator).to be(true)
    end
  end

  describe '#run' do
    subject(:mx_blacklist_validator) { mx_blacklist_validator_instance.run }

    let(:mx_blacklist_validator_instance) { described_class.new(result_instance) }
    let(:mail_servers) { Array.new(2) { random_ip_address } }
    let(:blacklisted_mx_ip_addresses) { [] }
    let(:configuration_instance) { create_configuration(blacklisted_mx_ip_addresses: blacklisted_mx_ip_addresses) }
    let(:mx_result_status) { true }
    let(:validator_instance) do
      create_validator(
        :mx,
        random_email,
        mail_servers,
        success: mx_result_status,
        configuration: configuration_instance
      )
    end
    let(:result_instance) { validator_instance.result }

    before do
      validator_instance
      allow(Truemail::Validate::Mx).to receive(:check).and_return(mx_result_status)
    end

    describe 'Success' do
      shared_examples 'not blacklisted mx server ip address' do
        specify do
          expect { mx_blacklist_validator }.not_to change(result_instance, :success)
          expect(result_instance.success).to be(true)
        end
      end

      context 'when ip list match validation not configured' do
        let(:configuration_instance) { create_configuration }

        it_behaves_like 'not blacklisted mx server ip address'
      end

      context 'when mx servers ip addresses not included in blacklisted mx ip address list' do
        it_behaves_like 'not blacklisted mx server ip address'
      end
    end

    describe 'Failure' do
      context 'when the previous validation layer fails' do
        let(:mx_result_status) { false }

        specify do
          expect { mx_blacklist_validator }.not_to change(result_instance, :success)
          expect(result_instance.success).to be(false)
        end
      end

      context 'when mx servers ip addresses included in blacklisted mx ip address list' do
        let(:blacklisted_mx_ip_addresses) { mail_servers.sample(1) }

        specify do
          expect { mx_blacklist_validator }
            .to change(result_instance, :success)
            .from(true).to(false)
            .and change(result_instance, :errors)
            .from({}).to(mx_blacklist: Truemail::Validate::MxBlacklist::ERROR)
        end
      end
    end
  end
end
