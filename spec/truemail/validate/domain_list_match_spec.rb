# frozen_string_literal: true

RSpec.describe Truemail::Validate::DomainListMatch do
  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:ERROR) }
  end

  describe 'inheritance' do
    specify { expect(described_class).to be < Truemail::Validate::Base }
  end

  describe '.check' do
    subject(:domain_list_match_validator) { described_class.check(result_instance) }

    let(:email) { random_email }
    let(:domain) { email[Truemail::RegexConstant::REGEX_DOMAIN_FROM_EMAIL, 1] }
    let(:configuration_instance) { create_configuration }
    let(:result_instance) { Truemail::Validator::Result.new(email: email, configuration: configuration_instance) }

    before do
      allow(configuration_instance).to receive(:whitelist_validation).and_return(whitelist_validation_condition)
    end

    context 'when whitelist validation not configured' do
      let(:whitelist_validation_condition) { false }

      context 'when email domain in white list' do
        specify do
          allow(configuration_instance).to receive(:whitelisted_domains).and_return([domain])
          allow(configuration_instance).to receive(:blacklisted_domains).and_return([])
          expect { domain_list_match_validator }.to change(result_instance, :success).from(nil).to(true)
        end
      end

      context 'when email domain in black list' do
        specify do
          allow(configuration_instance).to receive(:whitelisted_domains).and_return([])
          allow(configuration_instance).to receive(:blacklisted_domains).and_return([domain])
          expect { domain_list_match_validator }.to change(result_instance, :success)
            .from(nil).to(false)
            .and change(result_instance, :errors)
            .from({}).to(domain_list_match: Truemail::Validate::DomainListMatch::ERROR)
        end
      end

      context 'when email domain exists on both lists' do
        specify do
          allow(configuration_instance).to receive(:whitelisted_domains).and_return([domain])
          allow(configuration_instance).to receive(:blacklisted_domains).and_return([domain])
          expect { domain_list_match_validator }.to change(result_instance, :success).from(nil).to(true)
        end
      end

      context 'when email domain exists not on both lists' do
        specify do
          allow(configuration_instance).to receive(:whitelisted_domains).and_return([])
          allow(configuration_instance).to receive(:blacklisted_domains).and_return([])
          expect { domain_list_match_validator }.not_to change(result_instance, :success)
        end
      end
    end

    context 'when whitelist validation configured' do
      let(:whitelist_validation_condition) { true }

      context 'when email domain whitelisted in configuration' do
        before { allow(configuration_instance).to receive(:whitelisted_domains).and_return([domain]) }

        context 'when email domain in white list' do
          specify { expect { domain_list_match_validator }.not_to change(result_instance, :success) }
        end

        context 'when email domain exists on both lists' do
          specify do
            allow(configuration_instance).to receive(:blacklisted_domains).and_return([domain])
            expect { domain_list_match_validator }.to change(result_instance, :success)
              .from(nil).to(false)
              .and change(result_instance, :errors)
              .from({}).to(domain_list_match: Truemail::Validate::DomainListMatch::ERROR)
          end
        end
      end

      context 'when email domain not whitelisted in configuration' do
        before { allow(configuration_instance).to receive(:whitelisted_domains).and_return([]) }

        context 'when email domain in black list' do
          specify do
            allow(configuration_instance).to receive(:blacklisted_domains).and_return([domain])
            expect { domain_list_match_validator }.to change(result_instance, :success)
              .from(nil).to(false)
              .and change(result_instance, :errors)
              .from({}).to(domain_list_match: Truemail::Validate::DomainListMatch::ERROR)
          end
        end

        context 'when email domain not exists on both lists' do
          specify do
            allow(configuration_instance).to receive(:blacklisted_domains).and_return([])
            expect { domain_list_match_validator }.to change(result_instance, :success)
              .from(nil).to(false)
              .and change(result_instance, :errors)
              .from({}).to(domain_list_match: Truemail::Validate::DomainListMatch::ERROR)
          end
        end
      end
    end
  end
end
