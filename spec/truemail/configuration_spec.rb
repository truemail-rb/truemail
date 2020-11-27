# frozen_string_literal: true

RSpec.describe Truemail::Configuration do
  subject(:configuration_instance) { described_class.new }

  let(:valid_email) { FFaker::Internet.email }

  describe 'class constants' do
    context 'DEFAULT_CONNECTION_TIMEOUT' do
      specify { expect(described_class).to be_const_defined(:DEFAULT_CONNECTION_TIMEOUT) }
      specify { expect(described_class::DEFAULT_CONNECTION_TIMEOUT).to eq(2) }
    end

    context 'DEFAULT_RESPONSE_TIMEOUT' do
      specify { expect(described_class).to be_const_defined(:DEFAULT_RESPONSE_TIMEOUT) }
      specify { expect(described_class::DEFAULT_CONNECTION_TIMEOUT).to eq(2) }
    end

    context 'DEFAULT_CONNECTION_ATTEMPTS' do
      specify { expect(described_class).to be_const_defined(:DEFAULT_CONNECTION_ATTEMPTS) }
      specify { expect(described_class::DEFAULT_CONNECTION_TIMEOUT).to eq(2) }
    end

    context 'DEFAULT_VALIDATION_TYPE' do
      specify { expect(described_class).to be_const_defined(:DEFAULT_VALIDATION_TYPE) }
      specify { expect(described_class::DEFAULT_VALIDATION_TYPE).to eq(:smtp) }
    end

    context 'DEFAULT_LOGGER_OPTIONS' do
      specify { expect(described_class).to be_const_defined(:DEFAULT_LOGGER_OPTIONS) }
      specify { expect(described_class::DEFAULT_LOGGER_OPTIONS).to eq(tracking_event: :error, stdout: false, log_absolute_path: nil) }
    end
  end

  describe '.new' do
    %i[
      email_pattern
      smtp_error_body_pattern
      verifier_email
      verifier_domain
      connection_timeout
      response_timeout
      connection_attempts
      default_validation_type
      whitelisted_domains
      whitelist_validation
      blacklisted_domains
      not_rfc_mx_lookup_flow
      smtp_fail_fast
      smtp_safe_check
      logger
    ].each do |attribute|
      it "has attr_accessor :#{attribute}" do
        expect(configuration_instance.respond_to?(attribute)).to be(true)
        expect(configuration_instance.respond_to?(:"#{attribute}=")).to be(true)
      end
    end

    it 'has attribute reader :validation_type_by_domain' do
      expect(configuration_instance.respond_to?(:validation_type_by_domain)).to be(true)
    end

    it 'has attribute writer :validation_type_for=' do
      expect(configuration_instance.respond_to?(:validation_type_for=)).to be(true)
    end

    it 'accepts block' do
      expect(described_class.new(&configuration_block(verifier_email: valid_email)).verifier_email).to eq(valid_email)
    end

    it 'sets default configuration settings' do
      expect(configuration_instance.email_pattern).to eq(Truemail::RegexConstant::REGEX_EMAIL_PATTERN)
      expect(configuration_instance.smtp_error_body_pattern).to eq(Truemail::RegexConstant::REGEX_SMTP_ERROR_BODY_PATTERN)
      expect(configuration_instance.verifier_email).to be_nil
      expect(configuration_instance.verifier_domain).to be_nil
      expect(configuration_instance.connection_timeout).to eq(Truemail::Configuration::DEFAULT_CONNECTION_TIMEOUT)
      expect(configuration_instance.response_timeout).to eq(Truemail::Configuration::DEFAULT_RESPONSE_TIMEOUT)
      expect(configuration_instance.connection_attempts).to eq(Truemail::Configuration::DEFAULT_CONNECTION_ATTEMPTS)
      expect(configuration_instance.default_validation_type).to eq(Truemail::Configuration::DEFAULT_VALIDATION_TYPE)
      expect(configuration_instance.validation_type_by_domain).to eq({})
      expect(configuration_instance.whitelisted_domains).to eq([])
      expect(configuration_instance.whitelist_validation).to eq(false)
      expect(configuration_instance.blacklisted_domains).to eq([])
      expect(configuration_instance.not_rfc_mx_lookup_flow).to be(false)
      expect(configuration_instance.smtp_fail_fast).to be(false)
      expect(configuration_instance.smtp_safe_check).to be(false)
      expect(configuration_instance.logger).to be_nil
    end
  end

  describe 'configuration cases' do
    let(:default_verifier_domain) { valid_email[/\A(.+)@(.+)\z/, 2] }

    context 'when auto configuration' do
      let(:configuration_instance_expectaions) do
        expect(configuration_instance.email_pattern).to eq(Truemail::RegexConstant::REGEX_EMAIL_PATTERN)
        expect(configuration_instance.smtp_error_body_pattern).to eq(Truemail::RegexConstant::REGEX_SMTP_ERROR_BODY_PATTERN)
        expect(configuration_instance.connection_timeout).to eq(2)
        expect(configuration_instance.response_timeout).to eq(2)
        expect(configuration_instance.connection_attempts).to eq(2)
        expect(configuration_instance.default_validation_type).to eq(Truemail::Configuration::DEFAULT_VALIDATION_TYPE)
        expect(configuration_instance.validation_type_by_domain).to eq({})
        expect(configuration_instance.whitelisted_domains).to eq([])
        expect(configuration_instance.whitelist_validation).to eq(false)
        expect(configuration_instance.blacklisted_domains).to eq([])
        expect(configuration_instance.not_rfc_mx_lookup_flow).to be(false)
        expect(configuration_instance.smtp_fail_fast).to be(false)
        expect(configuration_instance.smtp_safe_check).to be(false)
        expect(configuration_instance.logger).to be_nil
      end

      it 'sets configuration instance with default configuration template' do
        expect { configuration_instance.verifier_email = valid_email }
          .to change(configuration_instance, :verifier_email)
          .from(nil).to(valid_email)
          .and change(configuration_instance, :verifier_domain)
          .from(nil).to(default_verifier_domain)
          .and change(configuration_instance, :complete?)
          .from(false).to(true)
          .and not_change(configuration_instance, :email_pattern)
          .and not_change(configuration_instance, :smtp_error_body_pattern)
          .and not_change(configuration_instance, :connection_timeout)
          .and not_change(configuration_instance, :response_timeout)
          .and not_change(configuration_instance, :default_validation_type)
          .and not_change(configuration_instance, :validation_type_by_domain)
          .and not_change(configuration_instance, :whitelisted_domains)
          .and not_change(configuration_instance, :whitelist_validation)
          .and not_change(configuration_instance, :blacklisted_domains)
          .and not_change(configuration_instance, :not_rfc_mx_lookup_flow)
          .and not_change(configuration_instance, :smtp_fail_fast)
          .and not_change(configuration_instance, :smtp_safe_check)
          .and not_change(configuration_instance, :logger)

        configuration_instance_expectaions
      end

      it 'sets configuration instance with default configuration template for upcase email' do
        expect { configuration_instance.verifier_email = valid_email.upcase }
          .to change(configuration_instance, :verifier_email)
          .from(nil).to(valid_email)
          .and change(configuration_instance, :verifier_domain)
          .from(nil).to(default_verifier_domain)
          .and change(configuration_instance, :complete?)
          .from(false).to(true)
          .and not_change(configuration_instance, :email_pattern)
          .and not_change(configuration_instance, :smtp_error_body_pattern)
          .and not_change(configuration_instance, :connection_timeout)
          .and not_change(configuration_instance, :response_timeout)
          .and not_change(configuration_instance, :default_validation_type)
          .and not_change(configuration_instance, :validation_type_by_domain)
          .and not_change(configuration_instance, :whitelisted_domains)
          .and not_change(configuration_instance, :whitelist_validation)
          .and not_change(configuration_instance, :blacklisted_domains)
          .and not_change(configuration_instance, :not_rfc_mx_lookup_flow)
          .and not_change(configuration_instance, :smtp_fail_fast)
          .and not_change(configuration_instance, :smtp_safe_check)
          .and not_change(configuration_instance, :logger)

        configuration_instance_expectaions
      end

      it 'sets configuration instance with default configuration template for mixcase email' do
        expect { configuration_instance.verifier_email = valid_email.capitalize }
          .to change(configuration_instance, :verifier_email)
          .from(nil).to(valid_email)
          .and change(configuration_instance, :verifier_domain)
          .from(nil).to(default_verifier_domain)
          .and change(configuration_instance, :complete?)
          .from(false).to(true)
          .and not_change(configuration_instance, :email_pattern)
          .and not_change(configuration_instance, :smtp_error_body_pattern)
          .and not_change(configuration_instance, :connection_timeout)
          .and not_change(configuration_instance, :response_timeout)
          .and not_change(configuration_instance, :default_validation_type)
          .and not_change(configuration_instance, :validation_type_by_domain)
          .and not_change(configuration_instance, :whitelisted_domains)
          .and not_change(configuration_instance, :whitelist_validation)
          .and not_change(configuration_instance, :blacklisted_domains)
          .and not_change(configuration_instance, :not_rfc_mx_lookup_flow)
          .and not_change(configuration_instance, :smtp_fail_fast)
          .and not_change(configuration_instance, :smtp_safe_check)
          .and not_change(configuration_instance, :logger)

        configuration_instance_expectaions
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

          it 'sets custom verifier domain for upcase domain' do
            expect { configuration_instance.verifier_domain = valid_domain.upcase }
              .to change(configuration_instance, :verifier_domain)
              .from(nil).to(valid_domain)
          end

          it 'sets custom verifier domain for mixcase domain' do
            expect { configuration_instance.verifier_domain = valid_domain.capitalize }
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

        context 'with invalid email pattern' do
          let(:setter) { :email_pattern= }

          include_examples 'raises argument error'
        end
      end

      describe '#smtp_error_body_pattern=' do
        context 'with valid value' do
          let(:valid_smtp_error_body_pattern) { /\d+/ }

          it 'sets custom email pattern' do
            expect { configuration_instance.smtp_error_body_pattern = valid_smtp_error_body_pattern }
              .to change(configuration_instance, :smtp_error_body_pattern)
              .from(Truemail::RegexConstant::REGEX_SMTP_ERROR_BODY_PATTERN).to(valid_smtp_error_body_pattern)
          end
        end

        context 'with invalid smtp error body pattern' do
          let(:setter) { :smtp_error_body_pattern= }

          include_examples 'raises argument error'
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

      describe '#connection_attempts=' do
        context 'with valid connection attempts' do
          it 'sets custom connection attempts' do
            expect { configuration_instance.connection_attempts = 3 }
              .to change(configuration_instance, :connection_attempts)
              .from(2).to(3)
          end
        end

        context 'with invalid connection attempts' do
          let(:setter) { :connection_attempts= }

          include_examples 'raises argument error'
        end
      end

      describe '#default_validation_type=' do
        context 'with valid value' do
          let(:valid_validation_type) { :mx }

          it 'sets default validation type' do
            expect { configuration_instance.default_validation_type = valid_validation_type }
              .to change(configuration_instance, :default_validation_type)
              .from(Truemail::Configuration::DEFAULT_VALIDATION_TYPE).to(valid_validation_type)
          end
        end

        context 'with invalid value' do
          shared_examples 'raises argument error' do
            specify do
              expect { configuration_instance.public_send(setter, invalid_validation_type) }
                .to raise_error(Truemail::ArgumentError, "#{invalid_validation_type} is not a valid #{setter}")
            end
          end

          let(:setter) { :default_validation_type= }

          context 'when value in not symbol' do
            let(:invalid_validation_type) { 'mx' }

            include_examples 'raises argument error'
          end

          context 'when value has wrong validation type' do
            let(:invalid_validation_type) { :not_valid_validation_type }

            include_examples 'raises argument error'
          end
        end
      end

      describe '#validation_type_for=' do
        context 'with valid validation type attributes' do
          let(:domains_config) do
            (1..3).map { FFaker::Internet.unique.domain_name }.zip(%i[regex mx smtp]).to_h
          end

          it 'sets validation type for domain' do
            expect { configuration_instance.validation_type_for = domains_config }
              .to change(configuration_instance, :validation_type_by_domain)
              .from({}).to(domains_config)
          end
        end

        context 'with invalid settings type' do
          let(:invalid_argument) { [] }

          specify do
            expect { configuration_instance.validation_type_for = invalid_argument }
              .to raise_error(Truemail::ArgumentError, "#{invalid_argument} is not a valid hash with settings")
          end
        end

        context 'with invalid domain' do
          let(:domain) { 'not_valid_domain' }

          specify do
            expect { configuration_instance.validation_type_for = { domain => '' } }
              .to raise_error(Truemail::ArgumentError, "#{domain} is not a valid domain")
          end
        end

        context 'with invalid validation type' do
          let(:domain)          { FFaker::Internet.domain_name }
          let(:validation_type) { 'wrong_validation_type' }

          specify do
            expect { configuration_instance.validation_type_for = { domain => validation_type } }
              .to raise_error(Truemail::ArgumentError, "#{validation_type} is not a valid validation type")
          end
        end
      end

      %i[whitelisted_domains= blacklisted_domains=].each do |domain_list_type|
        describe "##{domain_list_type}" do
          let(:domains_list) { (1..3).map { FFaker::Internet.unique.domain_name } }

          context "with valid #{domain_list_type} parameter type and context" do
            it 'sets whitelisted domains list' do
              expect { configuration_instance.public_send(domain_list_type, domains_list) }
                .to change(configuration_instance, domain_list_type[0...-1].to_sym)
                .from([]).to(domains_list)
            end
          end

          context "with invalid #{domain_list_type} parameter type" do
            let(:wrong_parameter_type) { 'not_array' }

            specify do
              expect { configuration_instance.public_send(domain_list_type, wrong_parameter_type) }
                .to raise_error(Truemail::ArgumentError, "#{wrong_parameter_type} is not a valid #{domain_list_type}")
            end
          end

          context 'with invalid whitelisted_domains= parameter context' do
            let(:wrong_parameter_context) { ['not_domain', 123] }

            specify do
              expect { configuration_instance.public_send(domain_list_type, wrong_parameter_context) }
                .to raise_error(Truemail::ArgumentError, "#{wrong_parameter_context} is not a valid #{domain_list_type}")
            end
          end
        end
      end

      describe '#not_rfc_mx_lookup_flow=' do
        it 'sets not RFC MX lookup flow' do
          expect { configuration_instance.not_rfc_mx_lookup_flow = true }
            .to change(configuration_instance, :not_rfc_mx_lookup_flow)
            .from(false).to(true)
        end
      end

      describe '#smtp_fail_fast=' do
        it 'sets smtp fail fast behaviour' do
          expect { configuration_instance.smtp_fail_fast = true }
            .to change(configuration_instance, :smtp_fail_fast)
            .from(false).to(true)
        end
      end

      describe '#smtp_safe_check=' do
        it 'sets smtp safe check' do
          expect { configuration_instance.smtp_safe_check = true }
            .to change(configuration_instance, :smtp_safe_check)
            .from(false).to(true)
        end
      end

      describe '#logger=' do
        let(:set_logger) { configuration_instance.logger = logger_params }

        context 'with valid logger settings' do
          shared_examples 'sets logger instance' do
            it 'sets logger instance' do
              expect { set_logger }.to change(configuration_instance, :logger)
                .from(nil).to(Truemail::Logger)
            end
          end

          let(:default_tracking_events_expectation) { expect(configuration_instance.logger.event).to eq(:error) }

          context 'when stdout only' do
            let(:logger_params) { { stdout: true } }

            include_examples 'sets logger instance'

            it 'sets logger configuration' do
              set_logger
              default_tracking_events_expectation
              expect(configuration_instance.logger.stdout).to be(true)
            end
          end

          context 'when file only' do
            let(:logger_params) { { log_absolute_path: 'some_absolute_path' } }

            include_examples 'sets logger instance'

            it 'sets logger configuration' do
              set_logger
              default_tracking_events_expectation
              expect(configuration_instance.logger.file).to be(logger_params[:log_absolute_path])
            end
          end

          context 'when stdout and file outputs' do
            let(:logger_params) { { stdout: true, log_absolute_path: 'some_absolute_path' } }

            include_examples 'sets logger instance'

            it 'sets logger configuration' do
              set_logger
              default_tracking_events_expectation
              expect(configuration_instance.logger.stdout).to be(true)
              expect(configuration_instance.logger.file).to be(logger_params[:log_absolute_path])
            end
          end

          context 'with valid tracking event' do
            shared_examples 'sets logger instance with custom tracking event' do
              it 'sets tracking event' do
                set_logger
                expect(configuration_instance.logger.event).to eq(event)
              end
            end

            Truemail::Log::Event::TRACKING_EVENTS.each_key do |tracking_event|
              context "when #{tracking_event} tracking event" do
                let(:event) { tracking_event }
                let(:logger_params) { { tracking_event: event, stdout: true } }

                it_behaves_like 'sets logger instance with custom tracking event'
              end
            end
          end
        end

        context 'with invalid logger setting' do
          shared_examples 'raises logger argument error' do
            specify { expect { set_logger }.to raise_error(Truemail::ArgumentError, error_message) }
          end

          context 'with empty params' do
            let(:logger_params) { {} }
            let(:error_message) { ' is not a valid logger=' }

            include_examples 'raises logger argument error'
          end

          context 'with log_absolute_path wrong type' do
            let(:log_absolute_path) { true }
            let(:logger_params) { { log_absolute_path: log_absolute_path } }
            let(:error_message) { "#{log_absolute_path} is not a valid logger=" }

            include_examples 'raises logger argument error'
          end

          context 'when attempt configure logger without output' do
            let(:stdout) { false }
            let(:logger_params) { { stdout: stdout } }
            let(:error_message) { ' is not a valid logger=' }

            include_examples 'raises logger argument error'
          end

          context 'with not existing tracking event' do
            let(:tracking_event) { :not_existing_tracking_event }
            let(:logger_params) { { tracking_event: tracking_event } }
            let(:error_message) { "#{tracking_event} is not a valid logger=" }

            include_examples 'raises logger argument error'
          end
        end
      end
    end
  end
end
