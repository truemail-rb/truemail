# frozen_string_literal: true

RSpec.describe Truemail::Validate::DomainListMatch do
  describe '.check' do
    subject(:list_match_validator) { described_class.check(result_instance) }

    let(:email) { FFaker::Internet.email }
    let(:domain) { email[Truemail::RegexConstant::REGEX_DOMAIN_FROM_EMAIL, 1] }
    let(:result_instance) { Truemail::Validator::Result.new(email: email) }

    context 'when email domain in white list' do
      specify do
        allow(Truemail).to receive_message_chain(:configuration, :whitelisted_domains).and_return([domain])
        allow(Truemail).to receive_message_chain(:configuration, :blacklisted_domains).and_return([])
        expect { list_match_validator }.to change(result_instance, :success).from(nil).to(true)
      end
    end

    context 'when email domain in black list' do
      specify do
        allow(Truemail).to receive_message_chain(:configuration, :whitelisted_domains).and_return([])
        allow(Truemail).to receive_message_chain(:configuration, :blacklisted_domains).and_return([domain])
        expect { list_match_validator }.to change(result_instance, :success).from(nil).to(false)
      end
    end

    context 'when email domain not on both lists' do
      specify do
        allow(Truemail).to receive_message_chain(:configuration, :whitelisted_domains).and_return([])
        allow(Truemail).to receive_message_chain(:configuration, :blacklisted_domains).and_return([])
        expect { list_match_validator }.not_to change(result_instance, :success)
      end
    end
  end
end
