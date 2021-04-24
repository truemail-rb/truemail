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

    let(:mail_servers) { Array.new(2) { random_ip_address } }
    let(:configuration_instance) { create_configuration(blacklisted_mx_ip_addresses: blacklisted_mx_ip_addresses) }
    let(:validator_instance) do
      create_validator(
        :mx,
        random_email,
        mail_servers,
        success: true,
        configuration: configuration_instance
      )
    end
    let(:result_instance) { validator_instance.result }

    describe 'Success' do
      shared_examples 'not blacklisted mx server ip address' do
        specify { expect { mx_blacklist_validator }.not_to change(result_instance, :success) }
      end

      context 'when ip list match validation not configured' do
        let(:configuration_instance) { create_configuration }

        it_behaves_like 'not blacklisted mx server ip address'
      end

      context 'when mx servers ip addresses not included in blacklisted mx ip address list' do
        let(:blacklisted_mx_ip_addresses) { [] }

        it_behaves_like 'not blacklisted mx server ip address'
      end
    end

    describe 'Failure' do
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
