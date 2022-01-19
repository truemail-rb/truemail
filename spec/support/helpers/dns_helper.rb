# frozen_string_literal: true

module Truemail
  module DnsHelper
    LOCALHOST_IP_ADDRESS = '127.0.0.1'

    def dns_mock_gateway
      ["#{Truemail::DnsHelper::LOCALHOST_IP_ADDRESS}:#{dns_mock_server.port}"]
    end

    def dns_mock_records_by_email(email, dimension: 1)
      mx_records = ::Array.new(dimension) { random_domain_name }
      a_records = ::Array.new(dimension) { [Truemail::DnsHelper::LOCALHOST_IP_ADDRESS] }
      mx_records_dns_mock = mx_records.zip(a_records).to_h.transform_values { |value| { a: value } }
      { domain_from_email(email) => { mx: mx_records } }.merge(mx_records_dns_mock)
    end
  end
end
