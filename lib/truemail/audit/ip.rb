# frozen_string_literal: true

module Truemail
  module Audit
    class Ip < Truemail::Audit::Base
      GET_MY_IP_URL = 'https://api.ipify.org'
      IPIFY_ERROR = 'impossible to detect current host address via third party service'

      def run
        return add_warning(Truemail::Audit::Ip::IPIFY_ERROR) unless detect_current_host_ip
        Truemail::Audit::Dns.check(result)
        Truemail::Audit::Ptr.check(result)
      end

      private

      def detect_ip_via_ipify
        ::Net::HTTP.get(URI(Truemail::Audit::Ip::GET_MY_IP_URL))
      end

      def detect_current_host_ip
        result.current_host_ip = Truemail::Wrapper.call(configuration: configuration) do
          detect_ip_via_ipify
        end
      end
    end
  end
end
