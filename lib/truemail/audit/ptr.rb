# frozen_string_literal: true

module Truemail
  module Audit
    class Ptr < Truemail::Audit::Base
      require 'ipaddr'
      require 'resolv'

      NOT_FOUND = 'ptr record for current host address was not found'
      NOT_REFERENCES = 'ptr record does not reference to current verifier domain'

      def run
        return if ptr_records.empty? && add_warning(Truemail::Audit::Ptr::NOT_FOUND)
        return if ptr_references_to_verifier_domain?
        add_warning(Truemail::Audit::Ptr::NOT_REFERENCES)
      end

      private

      def current_host_address
        # Resolv.getaddress(Socket.gethostname)
        @current_host_address ||= Net::HTTP.get(URI('https://api.ipify.org'))
      end

      def current_host_reverse_lookup
        IPAddr.new(current_host_address).reverse
      end

      def ptr_records
        @ptr_records ||= Truemail::Wrapper.call do
          Resolv::DNS.new.getresources(
            current_host_reverse_lookup, Resolv::DNS::Resource::IN::PTR
          ).map { |ptr_record| ptr_record.name.to_s }
        end || []
      end

      def ptr_references_to_verifier_domain?
        ptr_records.include?(Truemail.configuration.verifier_domain)
      end
    end
  end
end
