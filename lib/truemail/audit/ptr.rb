# frozen_string_literal: true

module Truemail
  module Audit
    class Ptr < Truemail::Audit::Base
      PTR_NOT_FOUND = 'ptr record for current host ip address was not found'
      PTR_NOT_REFER = 'ptr record does not reference to current verifier domain'

      def run
        return add_warning(Truemail::Audit::Ptr::PTR_NOT_FOUND) if ptr_records.empty?
        return if ptr_refer_to_verifier_domain?
        add_warning(Truemail::Audit::Ptr::PTR_NOT_REFER)
      end

      private

      def current_host_reverse_lookup
        IPAddr.new(current_host_ip).reverse
      end

      def ptr_records
        @ptr_records ||= Truemail::Wrapper.call(configuration: configuration) do
          Resolv::DNS.new.getresources(
            current_host_reverse_lookup, Resolv::DNS::Resource::IN::PTR
          ).map { |ptr_record| ptr_record.name.to_s }
        end || []
      end

      def ptr_refer_to_verifier_domain?
        ptr_records.include?(verifier_domain)
      end
    end
  end
end
