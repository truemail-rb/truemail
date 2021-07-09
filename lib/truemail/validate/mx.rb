# frozen_string_literal: true

module Truemail
  module Validate
    class Mx < Truemail::Validate::Base
      ERROR = 'target host(s) not found'
      NULL_MX_RECORD = 'null_mx_record'

      def run
        return false unless Truemail::Validate::Regex.check(result)
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
        mail_servers.push(*(hosts.uniq - mail_servers))
      end

      def null_mx?(domain_mx_records)
        mx_record = domain_mx_records.first
        domain_mx_records.one? && mx_record.preference.zero? && mx_record.exchange.to_s.empty?
      end

      def domain_not_include_null_mx
        !mail_servers.include?(Truemail::Validate::Mx::NULL_MX_RECORD)
      end

      def mx_records(hostname)
        domain_mx_records = Truemail::Dns::Resolver.mx_records(hostname, configuration: configuration)
        return [Truemail::Validate::Mx::NULL_MX_RECORD] if null_mx?(domain_mx_records)
        domain_mx_records.sort_by(&:preference).flat_map do |mx_record|
          Truemail::Dns::Resolver.a_records(mx_record.exchange.to_s, configuration: configuration)
        end
      end

      def mail_servers_found?
        !mail_servers.empty?
      end

      def domain
        @domain ||= begin
          result.domain = result.email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3]
          result.punycode_email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3]
        end
      end

      def hosts_from_mx_records?
        fetch_target_hosts(mx_records(domain))
        mail_servers_found?
      end

      def a_record(hostname)
        Truemail::Dns::Resolver.a_record(hostname, configuration: configuration)
      end

      def hosts_from_cname_records?
        cname_records = Truemail::Dns::Resolver.cname_records(domain, configuration: configuration)
        return if cname_records.empty?
        cname_records.each do |cname_record|
          host = a_record(cname_record.name.to_s)
          hostname = Truemail::Dns::Resolver.dns_lookup(host, configuration: configuration)
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
