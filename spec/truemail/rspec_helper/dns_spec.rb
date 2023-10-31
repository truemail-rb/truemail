# frozen_string_literal: true

RSpec.describe Truemail::RspecHelper::Dns, type: :helper do
  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:LOCALHOST_IP_ADDRESS) }
  end

  describe '#dns_mock_gateway' do
    specify do
      expect(dns_mock_gateway).to eq(["#{described_class::LOCALHOST_IP_ADDRESS}:#{dns_mock_server.port}"])
    end
  end

  describe '#dns_mock_records_by_email' do
    let(:email) { 'user@domain.com' }
    let(:email_domain) { 'domain.com' }
    let(:mx_domain) { 'mx.example.com' }

    before { allow(FFaker::Internet).to receive(:domain_name).and_return(mx_domain) }

    specify do
      dns_mock_records = dns_mock_records_by_email(email)
      expect(dns_mock_records.dig(email_domain, :mx).size).to eq(1)
      expect(dns_mock_records).to eq(
        email_domain => { mx: [mx_domain] },
        mx_domain => { a: [Truemail::RspecHelper::Dns::LOCALHOST_IP_ADDRESS] }
      )
    end

    specify do
      expect(
        dns_mock_records_by_email(email, dimension: 2).dig(email_domain, :mx).size
      ).to eq(2)
    end
  end
end
