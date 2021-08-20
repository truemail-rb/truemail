# frozen_string_literal: true

RSpec.describe Truemail::DnsHelper, type: :helper do # rubocop:disable RSpec/FilePath
  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:LOCALHOST_IP_ADDRESS) }
  end

  describe '#dns_mock_gateway' do
    specify do
      expect(dns_mock_gateway).to eq(["#{described_class::LOCALHOST_IP_ADDRESS}:#{dns_mock_server.port}"])
    end
  end
end
