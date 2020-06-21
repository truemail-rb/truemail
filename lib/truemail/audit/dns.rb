# frozen_string_literal: true

module Truemail
  module Audit
    class Dns < Truemail::Audit::Base
      VERIFIER_DOMAIN_NOT_REFER = 'a record of verifier domain not refers to current host ip address'

      def run
        return if verifier_domain_refer_to_current_host_ip?
        add_warning(Truemail::Audit::Dns::VERIFIER_DOMAIN_NOT_REFER)
      end

      private

      def a_record
        Truemail::Wrapper.call(configuration: configuration) do
          Resolv::DNS.new.getaddress(verifier_domain).to_s
        end
      end

      def verifier_domain_refer_to_current_host_ip?
        a_record.eql?(current_host_ip)
      end
    end
  end
end
