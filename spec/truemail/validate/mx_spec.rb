# frozen_string_literal: true

RSpec.describe Truemail::Validate::Mx do
  let(:email) { FFaker::Internet.email }
  let(:result_instance) { Truemail::Validator::Result.new(email: email) }

  before { Truemail.configure { |config| config.verifier_email = email } }

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:ERROR) }
  end

  describe '.check' do
    subject(:mx_validator) { described_class.check(result_instance) }

    let(:mx_validator_instance) { instance_double(described_class, run: true) }

    it 'receive #run' do
      allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
      allow(described_class).to receive(:new).and_return(mx_validator_instance)
      expect(mx_validator_instance).to receive(:run)
      expect(mx_validator).to be(true)
    end
  end

  describe '#run' do
    subject(:mx_validator) { mx_validator_instance.run }

    let(:mx_validator_instance) { described_class.new(result_instance) }

    context 'when validation pass' do
      let(:host_address) { FFaker::Internet.ip_v4_address }
      let(:host_name) { FFaker::Internet.domain_name }
      let(:mail_servers_by_ip) { Array.new(5) { host_address } }
      let(:mx_records_object) { YAML.load(File.open(mx_records_file, 'r')) }

      before do
        allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
        result_instance.success = true
      end

      context 'when mx records found' do
        let(:mx_records_file) { "#{File.expand_path('../../', __dir__)}/support/objects/mx_records.yml" }

        before do
          allow(Resolv::DNS).to receive_message_chain(:new, :getresources).and_return(mx_records_object)
          allow(Resolv).to receive(:getaddress).and_return(host_address)
        end

        specify do
          expect(mx_validator_instance).to receive(:hosts_from_mx_records?).and_call_original
          expect(mx_validator_instance).not_to receive(:hosts_from_cname_records?)
          expect(mx_validator_instance).not_to receive(:host_from_a_record?)

          expect { mx_validator }
            .to change(result_instance, :domain)
            .from(nil).to(email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3])
            .and change(result_instance, :mail_servers)
            .from([]).to(mail_servers_by_ip)
            .and not_change(result_instance, :success)
        end

        it 'returns true' do
          expect(mx_validator).to be(true)
        end
      end

      context 'when cname records found' do
        let(:cname_records_file) { "#{File.expand_path('../../', __dir__)}/support/objects/cname_records.yml" }
        let(:cname_records_object) { YAML.load(File.open(cname_records_file, 'r')) }

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
              .from([]).to(mail_servers_by_ip)
              .and not_change(result_instance, :success)
          end

          it 'returns true' do
            expect(mx_validator).to be(true)
          end
        end

        context 'when mx records not found' do
          before do
            allow(Resolv::DNS).to receive_message_chain(:new, :getresources).and_return(cname_records_object)
            allow(mx_validator_instance).to receive(:mx_records).and_return([])
          end

          specify do
            expect(mx_validator_instance).to receive(:hosts_from_cname_records?).and_call_original
            expect(mx_validator_instance).not_to receive(:host_from_a_record?)

            expect { mx_validator }
              .to change(result_instance, :domain)
              .from(nil).to(email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3])
              .and change(result_instance, :mail_servers)
              .from([]).to([host_address])
              .and not_change(result_instance, :success)
          end

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

        it 'returns true' do
          expect(mx_validator).to be(true)
        end
      end
    end

    context 'when validation fails' do
      context 'when regex pass' do
        before do
          allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
          result_instance.success = true
          allow(mx_validator_instance).to receive(:hosts_from_mx_records?)
          allow(mx_validator_instance).to receive(:hosts_from_cname_records?)
          allow(mx_validator_instance).to receive(:host_from_a_record?)
        end

        specify do
          expect { mx_validator }
            .to change(result_instance, :domain)
            .from(nil).to(email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3])
            .and not_change(result_instance, :mail_servers)
            .and change(result_instance, :success).from(true).to(false)
            .and change(result_instance, :errors).from({}).to({ mx: Truemail::Validate::Mx::ERROR })
        end

        it 'returns false' do
          expect(mx_validator).to be(false)
        end
      end

      context 'when regex fails' do
        before do
          allow(Truemail::Validate::Regex).to receive(:check).and_return(false)
          result_instance.success = false
        end

        specify do
          expect { mx_validator }.to not_change(result_instance, :success)
        end

        it 'returns false' do
          expect(mx_validator).to be(false)
        end
      end
    end
  end
end
