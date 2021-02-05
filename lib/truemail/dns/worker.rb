# frozen_string_literal: true

module Truemail
  module Dns
    require 'resolv'

    class Worker < ::Resolv::DNS
      DEFAULT_DNS_PORT = 53

      attr_reader :dns_gateway

      def initialize(dns_servers)
        super(dns_servers.empty? ? nil : config_info(dns_servers))
      end

      def dns_lookup(host_address)
        getname(host_address).to_s
      end

      def a_record(host_name)
        getaddress(host_name).to_s
      end

      def a_records(host_name)
        getaddresses(host_name).map(&:to_s)
      end

      def cname_records(host_name)
        getresources(host_name, ::Resolv::DNS::Resource::IN::CNAME)
      end

      def mx_records(host_name)
        getresources(host_name, ::Resolv::DNS::Resource::IN::MX)
      end

      def ptr_records(host_address)
        getresources(host_address, ::Resolv::DNS::Resource::IN::PTR)
      end

      private

      def nameserver_port(server)
        server_address, server_port = server.split(':')
        [server_address, server_port ? server_port.to_i : Truemail::Dns::Worker::DEFAULT_DNS_PORT]
      end

      def config_info(dns_servers)
        @dns_gateway = { nameserver_port: dns_servers.map { |server| nameserver_port(server) } }
      end
    end
  end
end
