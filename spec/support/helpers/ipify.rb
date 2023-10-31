# frozen_string_literal: true

module Truemail
  module RspecHelper
    module Ipify
      def mock_ipify_request(mocked_ipify_response, uri = Truemail::Audit::Ip::GET_MY_IP_URL)
        stub_request(:get, uri).with(
          headers: { 'Host' => URI(uri).host }
        ).to_return(body: mocked_ipify_response)
      end
    end
  end
end
