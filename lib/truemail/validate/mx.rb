# frozen_string_literal: true

module Truemail
  module Validate
    class Mx < Truemail::Validate::Base
      require 'resolv'

      ERROR = 'target host(s) not found'
      NULL_MX_RECORD = 'null_mx_record'

      def run
        return false unless Truemail::Validate::Regex.check(result)
        result.domain = result.punycode_email[Truemail::RegexConstant::REGEX_DOMAIN_FROM_EMAIL, 1]
        return true if success(mx_lookup && domain_not_include_null_mx)
        mail_servers.clear && add_error(Truemail::Validate::Mx::ERROR)
        false
      end

      private

      def host_extractor_methods
        return %i[hosts_from_mx_records?] if configuration.not_rfc_mx_lookup_flow
        %i[hosts_from_mx_records? hosts_from_cname_records? host_from_a_record?]
      end

      def mx_lookup
        host_extractor_methods.any? do |method|
          Truemail::Wrapper.call(configuration: configuration) { send(method) }
        end
      end

      def fetch_target_hosts(hosts)
        mail_servers.push(*hosts)
      end

      def null_mx?(domain_mx_records)
        mx_record = domain_mx_records.first
        domain_mx_records.one? && mx_record.preference.zero? && mx_record.exchange.to_s.empty?
      end

      def domain_not_include_null_mx
        !mail_servers.include?(Truemail::Validate::Mx::NULL_MX_RECORD)
      end

      def mx_records(hostname)
        domain_mx_records = Resolv::DNS.new.getresources(hostname, Resolv::DNS::Resource::IN::MX)
        return [Truemail::Validate::Mx::NULL_MX_RECORD] if null_mx?(domain_mx_records)
        domain_mx_records.sort_by(&:preference).map do |mx_record|
          Resolv.getaddresses(mx_record.exchange.to_s)
        end.flatten
      end

      def mail_servers_found?
        !mail_servers.empty?
      end

      def domain
        result.domain
      end

      def hosts_from_mx_records?
        fetch_target_hosts(mx_records(domain))
        mail_servers_found?
      end

      def a_record(hostname)
        Resolv.getaddress(hostname)
      end

      def hosts_from_cname_records?
        cname_records = Resolv::DNS.new.getresources(domain, Resolv::DNS::Resource::IN::CNAME)
        return if cname_records.empty?
        cname_records.each do |cname_record|
          host = a_record(cname_record.name.to_s)
          hostname = Resolv.getname(host)
          found_hosts = mx_records(hostname)
          fetch_target_hosts(found_hosts.empty? ? [host] : found_hosts)
        end
        mail_servers_found?
      end

      def host_from_a_record?
        fetch_target_hosts([a_record(domain)])
        mail_servers_found?
      end
    end
  end
end
