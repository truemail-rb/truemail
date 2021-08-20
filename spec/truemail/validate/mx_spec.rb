# frozen_string_literal: true

RSpec.describe Truemail::Validate::Mx do
  let(:email) { random_email }
  let(:configuration) { create_configuration(dns: dns_mock_gateway) }
  let(:result_instance) { Truemail::Validator::Result.new(email: email, configuration: configuration) }

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:ERROR) }
    specify { expect(described_class).to be_const_defined(:NULL_MX_RECORD) }
  end

  describe 'inheritance' do
    specify { expect(described_class).to be < Truemail::Validate::Base }
  end

  describe '.check' do
    subject(:mx_validator) { described_class.check(result_instance) }

    let(:mx_validator_instance) { instance_double(described_class, run: true) }

    it 'receive #run' do
      allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
      expect(described_class).to receive(:new).and_return(mx_validator_instance)
      expect(mx_validator_instance).to receive(:run)
      expect(mx_validator).to be(true)
    end
  end

  describe '#run' do
    subject(:mx_validator) { mx_validator_instance.run }

    let(:mx_validator_instance) { described_class.new(result_instance) }

    shared_examples 'calls email punycode representer, returns memoized result' do
      specify do
        expect(result_instance).to receive(:punycode_email).and_call_original
        mx_validator
        expect(mx_validator_instance.send(:domain)).to eq(email_punycode_domain(email))
      end
    end

    shared_context 'when internationalized email' do
      context 'when internationalized email' do
        let(:email) { random_internationalized_email }

        include_examples 'calls email punycode representer, returns memoized result'
      end
    end

    context 'when validation pass' do
      before do
        allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
        result_instance.success = true
      end

      context 'when mx records found' do
        let(:total_records) { 2 }
        let(:mx_records) { ::Array.new(total_records) { random_domain_name } }
        let(:a_record) { random_ip_address }
        let(:a_records) { ::Array.new(total_records) { [random_ip_address, a_record] } }
        let(:uniq_mail_servers_by_ip) { a_records.flatten.uniq }
        let(:mx_records_dns_mock) { mx_records.zip(a_records).to_h.transform_values { |value| { a: value } } }
        let(:dns_mock_records) { { domain_from_email(email) => { mx: mx_records } }.merge(mx_records_dns_mock) }

        before { dns_mock_server.assign_mocks(dns_mock_records) }

        context 'without null mx' do
          specify do
            expect(mx_validator_instance).to receive(:hosts_from_mx_records?).and_call_original
            expect(mx_validator_instance).to receive(:mx_records).and_call_original
            expect(mx_validator_instance).to receive(:null_mx?).and_call_original
            expect(mx_validator_instance).not_to receive(:hosts_from_cname_records?)
            expect(mx_validator_instance).not_to receive(:host_from_a_record?)

            expect { mx_validator }
              .to change(result_instance, :mail_servers)
              .from([]).to(uniq_mail_servers_by_ip)
              .and not_change(result_instance, :success)
          end

          include_examples 'calls email punycode representer, returns memoized result'

          specify { expect(mx_validator).to be(true) }

          include_context 'when internationalized email'
        end
      end

      context 'when cname records found' do
        let(:total_records) { 2 }
        let(:cname_records) { [random_domain_name] }
        let(:a_records) { [random_ip_address] }
        let(:mx_records) { ::Array.new(total_records) { random_domain_name } }
        let(:a_record) { random_ip_address }
        let(:mx_a_records) { ::Array.new(total_records) { [random_ip_address, a_record] } }
        let(:uniq_mail_servers_by_ip) { mx_a_records.flatten.uniq }
        let(:cname_records_dns_mock) { cname_records.zip(a_records).to_h.transform_values { |value| { a: [value], mx: mx_records } } }
        let(:ptr_records_dns_mock) { a_records.zip(cname_records).to_h.transform_values { |value| { ptr: [value] } } }
        let(:mx_records_dns_mock) { mx_records.zip(mx_a_records).to_h.transform_values { |value| { a: value } } }
        let(:dns_mock_records) do
          {
            domain_from_email(email) => { cname: cname_records.first }
          }.merge(cname_records_dns_mock).merge(ptr_records_dns_mock).merge(mx_records_dns_mock)
        end

        before { dns_mock_server.assign_mocks(dns_mock_records) }

        context 'when mx records found' do
          specify do
            expect(mx_validator_instance).to receive(:hosts_from_mx_records?).and_call_original
            expect(mx_validator_instance).to receive(:hosts_from_cname_records?).and_call_original
            expect(mx_validator_instance).not_to receive(:host_from_a_record?)

            expect { mx_validator }
              .to change(result_instance, :mail_servers)
              .from([]).to(uniq_mail_servers_by_ip)
              .and not_change(result_instance, :success)
          end

          include_examples 'calls email punycode representer, returns memoized result'

          specify { expect(mx_validator).to be(true) }

          include_context 'when internationalized email'
        end

        context 'when mx records not found' do
          let(:mx_records_dns_mock) { {} }
          let(:cname_records_dns_mock) { cname_records.zip(a_records).to_h.transform_values { |value| { a: [value] } } }

          specify do
            expect(mx_validator_instance).to receive(:hosts_from_cname_records?).and_call_original
            expect(mx_validator_instance).not_to receive(:host_from_a_record?)
            expect { mx_validator }
              .to change(result_instance, :mail_servers)
              .from([]).to([a_records.first]) # one cname record is equal to one a record
              .and not_change(result_instance, :success)
          end

          include_examples 'calls email punycode representer, returns memoized result'

          specify { expect(mx_validator).to be(true) }

          include_context 'when internationalized email'
        end
      end

      context 'when a record found' do
        let(:a_record) { random_ip_address }
        let(:dns_mock_records) { { domain_from_email(email) => { a: [a_record] } } }

        before { dns_mock_server.assign_mocks(dns_mock_records) }

        specify do
          expect(mx_validator_instance).to receive(:hosts_from_mx_records?).and_call_original
          expect(mx_validator_instance).to receive(:hosts_from_cname_records?).and_call_original
          expect(mx_validator_instance).to receive(:host_from_a_record?).and_call_original
          expect { mx_validator }
            .to change(result_instance, :mail_servers)
            .from([]).to([a_record])
            .and not_change(result_instance, :success)
        end

        include_examples 'calls email punycode representer, returns memoized result'

        specify { expect(mx_validator).to be(true) }

        include_context 'when internationalized email'
      end
    end

    context 'when validation fails' do
      shared_examples 'validation fails' do
        specify do
          mx_lookup_chain_expectations
          expect { mx_validator }
            .to change(result_instance, :success)
            .from(true).to(false)
            .and not_change(result_instance, :mail_servers)
        end

        include_examples 'calls email punycode representer, returns memoized result'

        specify { is_expected.to be(false) }
      end

      context 'when mx records found with null mx' do
        let(:dns_mock_records) { { domain_from_email(email) => { mx: %w[.:0] } } }
        let(:mx_lookup_chain_expectations) do
          expect(mx_validator_instance).to receive(:hosts_from_mx_records?).and_call_original
          expect(mx_validator_instance).not_to receive(:hosts_from_cname_records?)
          expect(mx_validator_instance).not_to receive(:host_from_a_record?)
        end

        before do
          allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
          result_instance.success = true
          dns_mock_server.assign_mocks(dns_mock_records)
        end

        include_examples 'validation fails'
        include_context 'when internationalized email'
      end

      context 'when not RFC MX lookup flow enabled' do
        let(:configuration) do
          create_configuration(
            not_rfc_mx_lookup_flow: true,
            dns: dns_mock_gateway
          )
        end
        let(:mx_lookup_chain_expectations) do
          expect(mx_validator_instance).to receive(:hosts_from_mx_records?).and_call_original
          expect(mx_validator_instance).not_to receive(:hosts_from_cname_records?)
          expect(mx_validator_instance).not_to receive(:host_from_a_record?)
        end

        before do
          allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
          result_instance.success = true
        end

        include_examples 'validation fails'
        include_context 'when internationalized email'
      end

      context 'when any of mx lookup methods fail' do
        let(:mx_lookup_chain_expectations) do
          expect(mx_validator_instance).to receive(:hosts_from_mx_records?).and_call_original
          expect(mx_validator_instance).to receive(:hosts_from_cname_records?).and_call_original
          expect(mx_validator_instance).to receive(:host_from_a_record?).and_call_original
        end

        before do
          allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
          result_instance.success = true
        end

        include_examples 'validation fails'
        include_context 'when internationalized email'
      end

      context 'when regex fails' do
        before do
          allow(Truemail::Validate::Regex).to receive(:check).and_return(false)
          result_instance.success = false
        end

        specify do
          expect(result_instance).not_to receive(:punycode_email)
          expect { mx_validator }.to not_change(result_instance, :success)
        end

        specify { is_expected.to be(false) }
      end
    end
  end
end
