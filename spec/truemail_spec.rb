# frozen_string_literal: true

RSpec.describe Truemail do
  let(:email) { random_email }
  let(:custom_configuration) { nil }

  shared_examples 'configuration error' do
    context 'when global configuration not set or custom configuration not passed' do
      specify do
        expect { subject }.to raise_error(Truemail::ConfigurationError, Truemail::NOT_CONFIGURED)
      end
    end
  end

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:INCOMPLETE_CONFIG) }
    specify { expect(described_class).to be_const_defined(:NOT_CONFIGURED) }
    specify { expect(described_class).to be_const_defined(:VERSION) }
    specify { expect(described_class).to be_const_defined(:Configuration) }
    specify { expect(described_class).to be_const_defined(:Worker) }
    specify { expect(described_class).to be_const_defined(:Executor) }
    specify { expect(described_class).to be_const_defined(:Wrapper) }
    specify { expect(described_class).to be_const_defined(:Auditor) }
    specify { expect(described_class).to be_const_defined(:Validator) }
    specify { expect(described_class).to be_const_defined(:Logger) }
    specify { expect(described_class).to be_const_defined(:ConfigurationError) }
    specify { expect(described_class).to be_const_defined(:TypeError) }
    specify { expect(described_class).to be_const_defined(:ArgumentError) }
    specify { expect(described_class).to be_const_defined(:RegexConstant) }
    specify { expect(described_class).to be_const_defined(:Audit) }
    specify { expect(described_class).to be_const_defined(:Validate) }
    specify { expect(described_class).to be_const_defined(:Log) }
  end

  describe 'global configuration methods' do
    describe '.configure' do
      subject(:configure) { described_class.configure(&config_block) }

      let(:config_block) { nil }

      context 'without block' do
        specify { expect(configure).to be_nil }
        specify { expect { configure }.not_to change(described_class, :configuration) }
      end

      context 'with block' do
        context 'without required parameter' do
          let(:config_block) { configuration_block }

          specify do
            expect { configure }
              .to raise_error(Truemail::ConfigurationError, Truemail::INCOMPLETE_CONFIG)
          end
        end

        context 'with valid required parameter' do
          let(:config_block) { configuration_block(verifier_email: email) }

          specify do
            expect { configure }
              .to change(described_class, :configuration)
              .from(nil).to(be_instance_of(Truemail::Configuration))
          end

          it 'sets attributes into configuration instance' do
            expect(configure).to be_an_instance_of(Truemail::Configuration)
            expect(described_class.configuration.verifier_email).to eq(email)
          end
        end
      end
    end

    describe '.reset_configuration!' do
      before { described_class.configure(&configuration_block(verifier_email: email)) }

      specify do
        expect { described_class.reset_configuration! }
          .to change(described_class, :configuration)
          .from(be_instance_of(Truemail::Configuration)).to(nil)
      end
    end

    describe '.configuration' do
      subject(:configuration) { described_class.configuration }

      before do
        described_class.configure(&configuration_block(
          verifier_email: email,
          verifier_domain: domain
        ))
      end

      let(:domain) { random_domain_name }
      let(:new_email) { random_email }
      let(:new_domain) { random_domain_name }
      let(:new_regex_pattern) { /\A+.\z/ }
      let(:new_smtp_error_body_pattern) { /\A\d+\z/ }

      specify { expect(configuration).to be_instance_of(Truemail::Configuration) }

      it 'accepts to rewrite current configuration settings' do
        expect do
          configuration.tap(&configuration_block(
            verifier_email: new_email,
            verifier_domain: new_domain,
            email_pattern: new_regex_pattern,
            smtp_error_body_pattern: new_smtp_error_body_pattern
          ))
        end
          .to change(configuration, :verifier_email)
          .from(email).to(new_email)
          .and change(configuration, :verifier_domain)
          .from(domain).to(new_domain)
          .and change(configuration, :email_pattern)
          .from(Truemail::RegexConstant::REGEX_EMAIL_PATTERN).to(new_regex_pattern)
          .and change(configuration, :smtp_error_body_pattern)
          .from(Truemail::RegexConstant::REGEX_SMTP_ERROR_BODY_PATTERN).to(new_smtp_error_body_pattern)
      end
    end
  end

  shared_context 'when passed email is not a String' do
    context 'when passed email is not a String' do
      let(:email) { nil }

      specify do
        expect { subject }.to raise_error(Truemail::TypeError, Truemail::INVALID_TYPE) # rubocop:disable RSpec/NamedSubject
      end
    end
  end

  describe '.validate' do
    subject(:validate) { described_class.validate(email, custom_configuration: custom_configuration) }

    shared_examples 'returns validator instance' do
      specify do
        allow(Truemail::Validate::Smtp).to receive(:check).and_return(true)
        expect(validate).to be_an_instance_of(Truemail::Validator)
      end
    end

    include_examples 'configuration error'

    context 'when passed email is a String' do
      context 'when global configuration successfully set' do
        before do
          described_class.configure do |config|
            config.verifier_email = 'admin@bestweb.com.ua'
            config.dns = dns_mock_gateway
            # config.smtp_port = smtp_mock_server.port # TODO: should be refactored with smtp-mock server in next release
          end
        end

        include_examples 'returns validator instance'

        describe 'integration tests' do
          let(:target_email) { random_email }
          let(:dns_mock_records) { dns_mock_records_by_email(target_email, dimension: 2) }

          before do
            dns_mock_server.assign_mocks(dns_mock_records)
            smtp_mock_server(**smtp_mock_server_options)
            stub_const('Truemail::Validate::Smtp::Request::SMTP_PORT', smtp_mock_server.port)
          end

          context 'when checks real email' do
            let(:smtp_mock_server_options) { {} }

            specify do
              expect(described_class.validate(target_email).result).to be_valid
            end
          end

          context 'when checks fake email' do
            let(:smtp_mock_server_options) { { not_registered_emails: [target_email] } }

            specify do
              expect(described_class.validate(target_email).result).not_to be_valid
            end
          end
        end
      end

      context 'when custom configuration passed' do
        let(:custom_configuration) { create_configuration }

        include_examples 'returns validator instance'
      end
    end

    include_context 'when passed email is not a String'
  end

  describe '.valid?' do
    subject(:valid_helper) { described_class.valid?(email, custom_configuration: custom_configuration) }

    shared_examples 'returns boolean' do
      it 'returns boolean from validator result instance' do
        allow(Truemail::Validate::Smtp).to receive(:check).and_return(true)
        allow_any_instance_of(Truemail::Validator::Result).to receive(:valid?).and_return(true)
        expect(valid_helper).to be(true)
      end
    end

    include_examples 'configuration error'

    context 'when passed email is a String' do
      context 'when global configuration successfully set' do
        before { described_class.configure { |config| config.verifier_email = email } }

        include_examples 'returns boolean'
      end

      context 'when custom configuration passed' do
        let(:custom_configuration) { create_configuration }

        include_examples 'returns boolean'
      end
    end

    include_context 'when passed email is not a String'
  end

  describe '.host_audit' do
    subject(:host_audit) { described_class.host_audit(custom_configuration: custom_configuration) }

    shared_examples 'returns auditor instance' do
      it 'returns auditor instance' do
        expect(Truemail::Auditor).to receive(:new).and_call_original
        expect_any_instance_of(Truemail::Auditor).to receive(:run).and_call_original
        expect(Truemail::Audit::Ip).to receive(:check).and_return(true)
        expect(host_audit).to be_an_instance_of(Truemail::Auditor)
      end
    end

    include_examples 'configuration error'

    context 'when global configuration successfully set' do
      before { described_class.configure { |config| config.verifier_email = email } }

      include_examples 'returns auditor instance'
    end

    context 'when custom configuration passed' do
      let(:custom_configuration) { create_configuration }

      include_examples 'returns auditor instance'
    end
  end
end
