# frozen_string_literal: true

module Truemail
  module DnsHelper
    LOCALHOST_IP_ADDRESS = '127.0.0.1'

    def dns_mock_gateway
      ["#{Truemail::DnsHelper::LOCALHOST_IP_ADDRESS}:#{dns_mock_server.port}"]
    end
  end
end
