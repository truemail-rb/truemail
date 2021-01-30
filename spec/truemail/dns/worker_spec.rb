# frozen_string_literal: true

RSpec.describe Truemail::Dns::Worker do
  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:DEFAULT_DNS_PORT) }
  end

  describe 'inheritance' do
    specify { expect(described_class).to be < ::Resolv::DNS }
  end

  describe '.new' do
    subject(:dns_resolver_worker) { described_class.new(dns_servers) }

    context 'without dns servers' do
      let(:dns_servers) { [] }

      specify 'creates dns resolver worker instance with default system dns gateway' do
        expect(dns_resolver_worker.dns_gateway).to be_nil
      end
    end

    context 'with dns servers' do
      let(:dns_servers) { %w[8.8.8.8 8.4.8.4:5300] }

      specify 'creates dns resolver worker instance with custom dns gateway' do
        expect(dns_resolver_worker.dns_gateway).to eq(nameserver_port: [['8.8.8.8', 53], ['8.4.8.4', 5300]])
      end
    end
  end

  def dns_resolver_worker_instance
    described_class.new(["localhost:#{dns_mock_server.port}"])
  end

  describe '#dns_lookup' do
    subject(:dns_lookup) { dns_resolver_worker_instance.dns_lookup(host_address) }

    let(:host_address) { Faker::Internet.ip_v4_address }
    let(:ptr_record) { Faker::Internet.domain_name }

    before { dns_mock_server.assign_mocks(host_address => { ptr: [ptr_record] }) }

    specify { expect(dns_lookup).to eq(ptr_record) }
  end

  describe '#a_record' do
    subject(:resolve_a_record) { dns_resolver_worker_instance.a_record(host_name) }

    let(:host_name) { Faker::Internet.domain_name }
    let(:a_record) { Faker::Internet.ip_v4_address }

    before { dns_mock_server.assign_mocks(host_name => { a: [a_record] }) }

    specify { expect(resolve_a_record).to eq(a_record) }
  end

  describe '#a_records' do
    subject(:resolve_a_records) { dns_resolver_worker_instance.a_records(host_name) }

    let(:host_name) { Faker::Internet.domain_name }
    let(:a_records) { ::Array.new(2) { Faker::Internet.ip_v4_address } }

    before { dns_mock_server.assign_mocks(host_name => { a: a_records }) }

    specify { expect(resolve_a_records.map(&:to_s)).to eq(a_records) }
  end

  describe '#cname_records' do
    subject(:resolve_cname_records) { dns_resolver_worker_instance.cname_records(host_name) }

    let(:host_name) { Faker::Internet.domain_name }
    let(:cname_record) { Faker::Internet.domain_name }

    before { dns_mock_server.assign_mocks(host_name => { cname: cname_record }) }

    specify { expect(resolve_cname_records.map { |record| record.name.to_s }).to eq([cname_record]) }
  end

  describe '#mx_records' do
    subject(:resolve_mx_records) { dns_resolver_worker_instance.mx_records(host_name) }

    let(:host_name) { Faker::Internet.domain_name }
    let(:mx_records) { ::Array.new(2) { Faker::Internet.domain_name } }

    before { dns_mock_server.assign_mocks(host_name => { mx: mx_records }) }

    specify { expect(resolve_mx_records.map { |record| record.exchange.to_s }).to eq(mx_records) }
  end

  describe '#ptr_records' do
    subject(:resolve_ptr_records) { dns_resolver_worker_instance.ptr_records(host_address) }

    # TODO: change it after update dns_mock
    # let(:host_address) { Faker::Internet.ip_v4_address }
    # should works with 42.42.42.42 or 42.42.42.42.in-addr.arpa; request for 42.42.42.42
    let(:host_address) { '42.42.42.42.in-addr.arpa' }
    let(:ptr_records) { ::Array.new(2) { Faker::Internet.domain_name } }

    before { dns_mock_server.assign_mocks(host_address => { ptr: ptr_records }) }

    specify { expect(resolve_ptr_records.map { |record| record.name.to_s }).to eq(ptr_records) }
  end
end
