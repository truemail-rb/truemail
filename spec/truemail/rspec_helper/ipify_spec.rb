# frozen_string_literal: true

RSpec.describe Truemail::RspecHelper::Ipify, type: :helper do
  describe '#mock_ipify_request' do
    let(:ip_address) { random_ip_address }

    specify do
      mock_ipify_request(ip_address)
      expect(::Net::HTTP.get(URI(Truemail::Audit::Ip::GET_MY_IP_URL))).to eq(ip_address)
    end
  end
end
