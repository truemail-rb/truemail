# frozen_string_literal: true

RSpec.describe Truemail::Validate::Mx do
  let(:email) { Faker::Internet.email }
  let(:configuration) { create_configuration }
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

    shared_examples 'calls email punycode representer' do
      specify do
        expect(result_instance).to receive(:punycode_email).and_call_original
        mx_validator
      end
    end

    context 'when validation pass' do
      let(:host_address) { Faker::Internet.ip_v4_address }
      let(:host_name) { Faker::Internet.domain_name }
      let(:mail_servers_by_ip) { Array.new(5) { host_address } }
      let(:uniq_mail_servers_by_ip) { [host_address] }
      let(:mx_records_object) { YAML.load(File.open(mx_records_file, 'r')) } # rubocop:disable Security/YAMLLoad

      before do
        allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
        result_instance.success = true
      end

      context 'when mx records found' do
        let(:mx_records_file) { "#{File.expand_path('../../', __dir__)}/support/objects/mx_records.yml" }

        before { allow(Resolv::DNS).to receive_message_chain(:new, :getresources).and_return(mx_records_object) }

        context 'without null mx' do
          before { allow(Resolv).to receive(:getaddresses).and_return([host_address]) }

          specify do
            expect(mx_validator_instance).to receive(:hosts_from_mx_records?).and_call_original
            expect(mx_validator_instance).to receive(:mx_records).and_call_original
            expect(mx_validator_instance).to receive(:null_mx?).and_call_original
            expect(mx_validator_instance).not_to receive(:hosts_from_cname_records?)
            expect(mx_validator_instance).not_to receive(:host_from_a_record?)

            expect { mx_validator }
              .to change(result_instance, :domain)
              .from(nil).to(email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3])
              .and change(result_instance, :mail_servers)
              .from([]).to(uniq_mail_servers_by_ip)
              .and not_change(result_instance, :success)
          end

          include_examples 'calls email punycode representer'

          it 'returns true' do
            expect(mx_validator).to be(true)
          end
        end
      end

      context 'when cname records found' do
        let(:cname_records_file) { "#{File.expand_path('../../', __dir__)}/support/objects/cname_records.yml" }
        let(:cname_records_object) { YAML.load(File.open(cname_records_file, 'r')) } # rubocop:disable Security/YAMLLoad

        before do
          allow(mx_validator_instance).to receive(:hosts_from_mx_records?)
          allow(Resolv).to receive(:getname).and_return(host_name)
          allow(Resolv).to receive(:getaddress).and_return(host_address)
        end

        context 'when mx records found' do
          before do
            allow(Resolv::DNS).to receive_message_chain(:new, :getresources).and_return(cname_records_object)
            allow(mx_validator_instance).to receive(:mx_records).and_return(mail_servers_by_ip)
          end

          specify do
            expect(mx_validator_instance).to receive(:hosts_from_cname_records?).and_call_original
            expect(mx_validator_instance).not_to receive(:host_from_a_record?)

            expect { mx_validator }
              .to change(result_instance, :domain)
              .from(nil).to(email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3])
              .and change(result_instance, :mail_servers)
              .from([]).to(uniq_mail_servers_by_ip)
              .and not_change(result_instance, :success)
          end

          include_examples 'calls email punycode representer'

          it 'returns true' do
            expect(mx_validator).to be(true)
          end
        end

        context 'when mx records not found' do
          before do # mock 2 cname records that refer to one specific ip address
            allow(Resolv::DNS).to receive_message_chain(:new, :getresources).and_return(cname_records_object * 2)
            allow(mx_validator_instance).to receive(:mx_records).and_return([])
          end

          specify do
            expect(mx_validator_instance).to receive(:hosts_from_cname_records?).and_call_original
            expect(mx_validator_instance).not_to receive(:host_from_a_record?)

            expect { mx_validator }
              .to change(result_instance, :domain)
              .from(nil).to(email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3])
              .and change(result_instance, :mail_servers)
              .from([]).to(uniq_mail_servers_by_ip) # have been collected only unique ip addresses
              .and not_change(result_instance, :success)
          end

          include_examples 'calls email punycode representer'

          it 'returns true' do
            expect(mx_validator).to be(true)
          end
        end
      end

      context 'when a record found' do
        before do
          allow(mx_validator_instance).to receive(:hosts_from_mx_records?)
          allow(mx_validator_instance).to receive(:hosts_from_cname_records?)
          allow(Resolv).to receive(:getaddress).and_return(host_address)
        end

        specify do
          expect { mx_validator }
            .to change(result_instance, :domain)
            .from(nil).to(email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3])
            .and change(result_instance, :mail_servers)
            .from([]).to([host_address])
            .and not_change(result_instance, :success)
        end

        include_examples 'calls email punycode representer'

        it 'returns true' do
          expect(mx_validator).to be(true)
        end
      end
    end

    context 'when validation fails' do
      let(:methods_calls_expectations) do
        expect(mx_validator_instance).not_to receive(:hosts_from_cname_records?)
        expect(mx_validator_instance).not_to receive(:host_from_a_record?)
      end

      shared_examples 'validation fails' do
        specify do
          methods_calls_expectations

          expect { mx_validator }
            .to change(result_instance, :domain)
            .from(nil).to(email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3])
            .and not_change(result_instance, :mail_servers)
            .and change(result_instance, :success).from(true).to(false)
        end

        include_examples 'calls email punycode representer'

        it 'returns false' do
          expect(mx_validator).to be(false)
        end
      end

      context 'when mx records found with null mx' do
        let(:mx_records_object) { YAML.load(File.open(mx_records_file, 'r')) } # rubocop:disable Security/YAMLLoad
        let(:mx_records_file) { "#{File.expand_path('../../', __dir__)}/support/objects/mx_records.yml" }
        let(:target_mx_record) { mx_records_object.first }

        before do
          allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
          result_instance.success = true
          allow(Resolv::DNS).to receive_message_chain(:new, :getresources).and_return(mx_records_object)
          allow(mx_validator_instance).to receive(:hosts_from_mx_records?).and_call_original
          allow(mx_validator_instance).to receive(:mx_records).and_call_original
          allow(mx_validator_instance).to receive(:null_mx?).and_call_original
          allow(mx_records_object).to receive(:one?).and_return(true)
          allow(target_mx_record).to receive_message_chain(:preference, :zero?).and_return(true)
          allow(target_mx_record).to receive_message_chain(:exchange, :to_s, :empty?).and_return(true)
        end

        include_examples 'validation fails'
      end

      context 'when not RFC MX lookup flow enabled' do
        let(:configuration) { create_configuration(not_rfc_mx_lookup_flow: true) }

        before do
          allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
          result_instance.success = true
          allow(mx_validator_instance).to receive(:hosts_from_mx_records?)
        end

        include_examples 'validation fails'
      end

      context 'when any of mx lookup methods fail' do
        let(:methods_calls_expectations) { nil }

        before do
          allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
          result_instance.success = true
          allow(mx_validator_instance).to receive(:hosts_from_mx_records?)
          allow(mx_validator_instance).to receive(:hosts_from_cname_records?)
          allow(mx_validator_instance).to receive(:host_from_a_record?)
        end

        include_examples 'validation fails'
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

        it 'returns false' do
          expect(mx_validator).to be(false)
        end
      end
    end
  end
end
