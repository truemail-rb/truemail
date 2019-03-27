# frozen_string_literal: true

RSpec.describe Truemail::Validate::Mx do
  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:ERROR) }
  end

  describe '.check' do
    subject(:mx_validator) { described_class.check(result_instance) }

    let(:email) { FFaker::Internet.email }
    let(:result_instance) { Truemail::Validator::Result.new(email: email) }
    let(:mx_records_object) { YAML.load(File.open(mx_records_file, 'r')) }

    context 'when validation pass' do
      let(:mx_records_file) { "#{File.expand_path('../../', __dir__)}/support/objects/mx_records.yml" }
      let(:mail_servers_sorted_by_preference) do
        [
          'gmail-smtp-in.l.google.com',
          'alt1.gmail-smtp-in.l.google.com',
          'alt2.gmail-smtp-in.l.google.com',
          'alt3.gmail-smtp-in.l.google.com',
          'alt4.gmail-smtp-in.l.google.com'
        ]
      end

      before do
        allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
        allow(Resolv::DNS).to receive(:open).and_return(mx_records_object)
        result_instance.success = true
      end

      specify do
        expect { mx_validator }
          .to change(result_instance, :domain)
          .from(nil).to(email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3])
          .and change(result_instance, :mail_servers)
          .from([]).to(mail_servers_sorted_by_preference)
          .and not_change(result_instance, :success)
      end

      it 'returns true' do
        expect(mx_validator).to be(true)
      end
    end

    context 'when validation fails' do
      context 'when regex pass' do
        before do
          allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
          result_instance.success = true
          allow(Resolv::DNS).to receive(:open).and_return([])
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
