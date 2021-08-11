# frozen_string_literal: true

RSpec.describe Truemail::ContextHelper, type: :helper do # rubocop:disable RSpec/FilePath
  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:NON_ASCII_WORDS) }
  end

  describe '#random_email' do
    specify do
      expect(FFaker::Internet).to receive(:email).and_call_original
      expect(random_email).to match(Truemail::RegexConstant::REGEX_EMAIL_PATTERN)
    end
  end

  describe '#random_domain_name' do
    specify do
      expect(FFaker::Internet).to receive(:domain_name).and_call_original
      expect(random_domain_name).to match(Truemail::RegexConstant::REGEX_DOMAIN_PATTERN)
    end
  end

  describe '#random_uniq_domain_name' do
    specify do
      expect(FFaker::Internet).to receive_message_chain(:unique, :domain_name)
      random_uniq_domain_name
    end

    specify { expect(random_domain_name).to match(Truemail::RegexConstant::REGEX_DOMAIN_PATTERN) }
  end

  describe '#random_ip_address' do
    specify do
      expect(FFaker::Internet).to receive(:ip_v4_address).and_call_original
      expect(random_ip_address).to match(Truemail::RegexConstant::REGEX_DNS_SERVER_ADDRESS_PATTERN)
    end
  end

  describe '#rdns_lookup_host_address' do
    specify do
      expect(rdns_lookup_host_address('10.20.30.40')).to eq('40.30.20.10.in-addr.arpa')
    end
  end

  describe '#domain_from_email' do
    let(:domain) { 'domain' }
    let(:email) { "user@#{domain}" }

    specify { expect(domain_from_email(email)).to eq(domain) }
  end

  describe '#email_punycode_domain' do
    let(:domain) { 'mañana.cøm' }
    let(:email) { "user@#{domain}" }

    specify { expect(email_punycode_domain(email)).to eq('xn--maana-pta.xn--cm-lka') }
  end

  describe '#random_internationalized_email' do
    let(:user) { 'user' }
    let(:domain_zone) { 'com' }
    let(:ascii_word) { 'mañana' }

    specify do
      stub_const("#{described_class}::NON_ASCII_WORDS", [ascii_word])
      expect(FFaker::Internet).to receive(:user_name).and_return(user)
      expect(FFaker::Internet).to receive(:domain_suffix).and_return(domain_zone)
      expect(random_internationalized_email).to eq("#{user}@#{ascii_word}.#{domain_zone}")
    end
  end
end
