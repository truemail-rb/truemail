# frozen_string_literal: true

RSpec.describe Truemail::Validate::ListMatch do
  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:ERROR) }
  end

  describe 'inheritance' do
    specify { expect(described_class).to be < Truemail::Validate::Base }
  end

  describe '.check' do
    subject(:domain_list_match_validator) { described_class.check(result_instance) }

    let(:email) { random_email }
    let(:domain) { domain_from_email(email) }
    let(:configuration_instance) { create_configuration }
    let(:result_instance) { Truemail::Validator::Result.new(email: email, configuration: configuration_instance) }

    before do
      allow(configuration_instance).to receive(:whitelist_validation).and_return(whitelist_validation_condition)
    end

    context 'when whitelist validation is not configured' do
      let(:whitelist_validation_condition) { false }

      context 'when email is in whitelist' do
        specify do
          allow(configuration_instance).to receive(:whitelisted_emails).and_return([email])
          expect { domain_list_match_validator }
            .to change(result_instance, :success)
            .from(nil).to(true)
            .and not_change(result_instance, :domain)
        end
      end

      context 'when email domain is in whitelist' do
        specify do
          allow(configuration_instance).to receive(:whitelisted_domains).and_return([domain])
          expect { domain_list_match_validator }
            .to change(result_instance, :success)
            .from(nil).to(true)
            .and change(result_instance, :domain)
            .from(nil).to(domain_from_email(email))
        end
      end

      context 'when email is in blacklist' do
        specify do
          allow(configuration_instance).to receive(:blacklisted_emails).and_return([email])
          expect { domain_list_match_validator }
            .to change(result_instance, :success)
            .from(nil).to(false)
            .and change(result_instance, :errors)
            .from({}).to(list_match: Truemail::Validate::ListMatch::ERROR)
            .and change(result_instance, :domain)
            .from(nil).to(domain_from_email(email))
        end
      end

      context 'when email domain is in blacklist' do
        specify do
          allow(configuration_instance).to receive(:blacklisted_domains).and_return([domain])
          expect { domain_list_match_validator }
            .to change(result_instance, :success)
            .from(nil).to(false)
            .and change(result_instance, :errors)
            .from({}).to(list_match: Truemail::Validate::ListMatch::ERROR)
            .and change(result_instance, :domain)
            .from(nil).to(domain_from_email(email))
        end
      end

      context 'when email is on both lists' do
        specify do
          allow(configuration_instance).to receive_messages(whitelisted_emails: [email], blacklisted_emails: [email])
          expect { domain_list_match_validator }
            .to change(result_instance, :success)
            .from(nil).to(true)
            .and not_change(result_instance, :domain)
        end
      end

      context 'when email domain is on both lists' do
        specify do
          allow(configuration_instance).to receive_messages(whitelisted_domains: [domain], blacklisted_domains: [domain])
          expect { domain_list_match_validator }
            .to change(result_instance, :success)
            .from(nil).to(true)
            .and change(result_instance, :domain)
            .from(nil).to(domain_from_email(email))
        end
      end

      context 'when email domain is on neither list' do
        specify do
          allow(configuration_instance).to receive_messages(whitelisted_domains: [], blacklisted_domains: [])
          expect { domain_list_match_validator }
            .to not_change(result_instance, :success)
            .and change(result_instance, :domain)
            .from(nil).to(domain_from_email(email))
        end
      end
    end

    context 'when whitelist validation is configured' do
      let(:whitelist_validation_condition) { true }

      context 'when email is whitelisted in configuration' do
        before { allow(configuration_instance).to receive(:whitelisted_emails).and_return([email]) }

        context 'when email is in whitelist' do
          specify do
            expect { domain_list_match_validator }
              .to not_change(result_instance, :success)
              .and change(result_instance, :domain)
              .from(nil).to(domain_from_email(email))
          end
        end

        context 'when email is on both lists' do
          specify do
            allow(configuration_instance).to receive(:blacklisted_emails).and_return([email])
            expect { domain_list_match_validator }
              .to change(result_instance, :success)
              .from(nil).to(false)
              .and change(result_instance, :errors)
              .from({}).to(list_match: Truemail::Validate::ListMatch::ERROR)
              .and not_change(result_instance, :domain)
          end
        end
      end

      context 'when email domain is whitelisted in configuration' do
        before { allow(configuration_instance).to receive(:whitelisted_domains).and_return([domain]) }

        context 'when email domain is in whitelist' do
          specify do
            expect { domain_list_match_validator }
              .to not_change(result_instance, :success)
              .and change(result_instance, :domain)
              .from(nil).to(domain_from_email(email))
          end
        end

        context 'when email domain is on both lists' do
          specify do
            allow(configuration_instance).to receive(:blacklisted_domains).and_return([domain])
            expect { domain_list_match_validator }
              .to change(result_instance, :success)
              .from(nil).to(false)
              .and change(result_instance, :errors)
              .from({}).to(list_match: Truemail::Validate::ListMatch::ERROR)
              .and change(result_instance, :domain)
              .from(nil).to(domain_from_email(email))
          end
        end
      end

      context 'when email is not whitelisted in configuration' do
        before { allow(configuration_instance).to receive(:whitelisted_emails).and_return([]) }

        context 'when email is in blacklist' do
          specify do
            allow(configuration_instance).to receive(:blacklisted_emails).and_return([email])
            expect { domain_list_match_validator }
              .to change(result_instance, :success)
              .from(nil).to(false)
              .and change(result_instance, :errors)
              .from({}).to(list_match: Truemail::Validate::ListMatch::ERROR)
              .and change(result_instance, :domain)
              .from(nil).to(domain_from_email(email))
          end
        end

        context 'when email is on neither list' do
          specify do
            allow(configuration_instance).to receive(:blacklisted_emails).and_return([])
            expect { domain_list_match_validator }
              .to change(result_instance, :success)
              .from(nil).to(false)
              .and change(result_instance, :errors)
              .from({}).to(list_match: Truemail::Validate::ListMatch::ERROR)
              .and change(result_instance, :domain)
              .from(nil).to(domain_from_email(email))
          end
        end
      end

      context 'when email domain is not whitelisted in configuration' do
        before { allow(configuration_instance).to receive(:whitelisted_domains).and_return([]) }

        context 'when email domain is in blacklist' do
          specify do
            allow(configuration_instance).to receive(:blacklisted_domains).and_return([domain])
            expect { domain_list_match_validator }
              .to change(result_instance, :success)
              .from(nil).to(false)
              .and change(result_instance, :errors)
              .from({}).to(list_match: Truemail::Validate::ListMatch::ERROR)
              .and change(result_instance, :domain)
              .from(nil).to(domain_from_email(email))
          end
        end

        context 'when email domain is on neither list' do
          specify do
            allow(configuration_instance).to receive(:blacklisted_domains).and_return([])
            expect { domain_list_match_validator }
              .to change(result_instance, :success)
              .from(nil).to(false)
              .and change(result_instance, :errors)
              .from({}).to(list_match: Truemail::Validate::ListMatch::ERROR)
              .and change(result_instance, :domain)
              .from(nil).to(domain_from_email(email))
          end
        end
      end
    end
  end
end
