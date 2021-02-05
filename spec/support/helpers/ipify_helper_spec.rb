# frozen_string_literal: true

RSpec.describe Truemail::IpifyHelper, type: :helper do # rubocop:disable RSpec/FilePath
  describe '#mock_ipify_request' do
    let(:ip_address) { Faker::Internet.ip_v4_address }

    specify do
      mock_ipify_request(ip_address)
      expect(::Net::HTTP.get(URI(Truemail::Audit::Ip::GET_MY_IP_URL))).to eq(ip_address)
    end
  end
end
