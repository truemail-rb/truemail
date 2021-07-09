# frozen_string_literal: true

RSpec.describe Truemail::ContextHelper, type: :helper do # rubocop:disable RSpec/FilePath
  describe '#random_email' do
    specify do
      expect(Faker::Internet).to receive(:email).and_call_original
      expect(random_email).to match(Truemail::RegexConstant::REGEX_EMAIL_PATTERN)
    end
  end

  describe '#random_domain_name' do
    specify do
      expect(Faker::Internet).to receive(:domain_name).and_call_original
      expect(random_domain_name).to match(Truemail::RegexConstant::REGEX_DOMAIN_PATTERN)
    end
  end

  describe '#random_uniq_domain_name' do
    specify do
      expect(Faker::Internet).to receive_message_chain(:unique, :domain_name)
      random_uniq_domain_name
    end

    specify { expect(random_domain_name).to match(Truemail::RegexConstant::REGEX_DOMAIN_PATTERN) }
  end

  describe '#random_ip_address' do
    specify do
      expect(Faker::Internet).to receive(:ip_v4_address).and_call_original
      expect(random_ip_address).to match(Truemail::RegexConstant::REGEX_DNS_SERVER_ADDRESS_PATTERN)
    end
  end

  describe '#rdns_lookup_host_address' do
    specify do
      expect(rdns_lookup_host_address('10.20.30.40')).to eq('40.30.20.10.in-addr.arpa')
    end
  end
end
