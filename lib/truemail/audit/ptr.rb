# frozen_string_literal: true

module Truemail
  module Audit
    class Ptr < Truemail::Audit::Base
      require 'ipaddr'
      require 'resolv'

      GET_MY_IP_URL = 'https://api.ipify.org'
      IPIFY_ERROR = 'impossible to detect current host address via third party service'
      PTR_NOT_FOUND = 'ptr record for current host address was not found'
      PTR_NOT_REFER = 'ptr record does not reference to current verifier domain'
      VERIFIER_DOMAIN_NOT_REFER = 'a record of verifier domain not refers to current host address'

      def run
        return if !current_host_address && add_warning(Truemail::Audit::Ptr::IPIFY_ERROR)
        return if ptr_records.empty? && add_warning(Truemail::Audit::Ptr::PTR_NOT_FOUND)
        return if ptr_not_refer_to_verifier_domain? && add_warning(Truemail::Audit::Ptr::PTR_NOT_REFER)
        return if verifier_domain_refer_to_current_host_address?
        add_warning(Truemail::Audit::Ptr::VERIFIER_DOMAIN_NOT_REFER)
      end

      private

      def detect_ip_via_ipify
        Net::HTTP.get(URI(Truemail::Audit::Ptr::GET_MY_IP_URL))
      end

      def current_host_address
        @current_host_address ||= Truemail::Wrapper.call(configuration: configuration) do
          IPAddr.new(detect_ip_via_ipify)
        end
      end

      def current_host_reverse_lookup
        current_host_address.reverse
      end

      def ptr_records
        @ptr_records ||= Truemail::Wrapper.call(configuration: configuration) do
          Resolv::DNS.new.getresources(
            current_host_reverse_lookup, Resolv::DNS::Resource::IN::PTR
          ).map { |ptr_record| ptr_record.name.to_s }
        end || []
      end

      def ptr_not_refer_to_verifier_domain?
        !ptr_records.include?(verifier_domain)
      end

      def a_record
        Truemail::Wrapper.call(configuration: configuration) do
          Resolv::DNS.new.getaddress(verifier_domain).to_s
        end
      end

      def verifier_domain_refer_to_current_host_address?
        a_record.eql?(current_host_address.to_s)
      end
    end
  end
end
