RSpec.describe Truemail::Configuration do
  subject(:configuration_instance) { described_class.new }

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:DEFAULT_CONNECTION_TIMEOUT) }
    specify { expect(described_class).to be_const_defined(:DEFAULT_RESPONSE_TIMEOUT) }
  end

  describe '.new' do
    include_examples 'has attr_accessor'
    include_examples 'sets default configuration'
  end

  describe 'configuration cases' do
    let(:valid_email) { FFaker::Internet.email }
    let(:default_verifier_domain) { valid_email[/\A(.+)@(.+)\z/, 2] }

    context 'when auto configuration' do
      it 'sets configuration instance with default configuration template' do
        expect { configuration_instance.verifier_email = valid_email }
          .to change(configuration_instance, :verifier_email)
          .from(nil).to(valid_email)
          .and change(configuration_instance, :verifier_domain)
          .from(nil).to(default_verifier_domain)
          .and change(configuration_instance, :complete?)
          .from(false).to(true)
          .and not_change(configuration_instance, :email_pattern)
          .and not_change(configuration_instance, :connection_timeout)
          .and not_change(configuration_instance, :response_timeout)

        expect(configuration_instance.email_pattern).to eq(Truemail::RegexConstant::REGEX_EMAIL_PATTERN)
        expect(configuration_instance.connection_timeout).to eq(2)
        expect(configuration_instance.response_timeout).to eq(2)
      end
    end

    context 'when manual independent configuration' do
      let(:valid_domain) { FFaker::Internet.domain_name }

      describe '#verifier_email=' do
        context 'with valid email' do
          before { configuration_instance.verifier_domain = valid_domain }

          it 'sets verifier email' do
            expect { configuration_instance.verifier_email = valid_email }
              .to change(configuration_instance, :verifier_email)
              .from(nil).to(valid_email)
              .and not_change(configuration_instance, :verifier_domain)
          end
        end

        context 'with invalid email' do
          let(:setter) { :verifier_email= }

          include_examples 'raises argument error'
        end
      end

      describe '#verifier_domain=' do
        context 'with valid domain' do
          it 'sets custom verifier domain' do
            expect { configuration_instance.verifier_domain = valid_domain }
              .to change(configuration_instance, :verifier_domain)
              .from(nil).to(valid_domain)
          end
        end

        context 'with invalid domain' do
          let(:setter) { :verifier_domain= }

          include_examples 'raises argument error'
        end
      end

      describe '#email_pattern=' do
        context 'with valid value' do
          let(:valid_regex_pattern) { /\d+/ }

          it 'sets custom email pattern' do
            expect { configuration_instance.email_pattern = valid_regex_pattern }
              .to change(configuration_instance, :email_pattern)
              .from(Truemail::RegexConstant::REGEX_EMAIL_PATTERN).to(valid_regex_pattern)
          end
        end

        context 'with invalid value' do
          specify do
            expect { configuration_instance.email_pattern = 'not_regex_object' }
              .to raise_error(Truemail::ArgumentError)
          end
        end
      end

      describe '#connection_timeout=' do
        context 'with valid connection timeout' do
          it 'sets custom connection timeout' do
            expect { configuration_instance.connection_timeout = 5 }
              .to change(configuration_instance, :connection_timeout)
              .from(2).to(5)
          end
        end

        context 'with invalid connection attempts' do
          let(:setter) { :connection_timeout= }

          include_examples 'raises argument error'
        end
      end

      describe '#response_timeout=' do
        context 'with valid response timeout' do
          it 'sets custom response timeout' do
            expect { configuration_instance.response_timeout = 5 }
              .to change(configuration_instance, :response_timeout)
              .from(2).to(5)
          end
        end

        context 'with invalid response timeout' do
          let(:setter) { :response_timeout= }

          include_examples 'raises argument error'
        end
      end
    end
  end
end
