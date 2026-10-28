# frozen_string_literal: true

module Truemail
  module Audit
    class Dns < Truemail::Audit::Base
      VERIFIER_DOMAIN_NOT_REFER = 'A record of verifier domain does not refer to current host IP address'

      def run
        return if verifier_domain_refers_to_current_host_ip?
        add_warning(Truemail::Audit::Dns::VERIFIER_DOMAIN_NOT_REFER)
      end

      private

      def a_record
        Truemail::Wrapper.call(configuration: configuration) do
          Truemail::Dns::Resolver.a_record(verifier_domain, configuration: configuration)
        end
      end

      def verifier_domain_refers_to_current_host_ip?
        a_record.eql?(current_host_ip)
      end
    end
  end
end
