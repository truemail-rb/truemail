# frozen_string_literal: true

module Truemail
  module ValidatorHelper
    def create_servers_list
      Array.new(rand(1..4)) { FFaker::Internet.ip_v4_address }
    end

    def create_validator(
      validation_type = nil,
      email = FFaker::Internet.email,
      mail_servers = create_servers_list,
      success: true,
      configuration: create_configuration
    )
      set_expected_result(validation_type, email, mail_servers, success, configuration)
      stub_validation_layers
      validator_instance = ValidatorFactory.call(validation_type, success, email, configuration)
      unstub_validation_layers
      validator_instance
    end

    private

    attr_reader :validation_type, :email, :success, :configuration, :mail_servers

    def set_expected_result(validation_type, email, mail_servers, success, configuration)
      @validation_type = validation_type
      @email = email
      @mail_servers = mail_servers
      @success = success
      @configuration = configuration
    end

    def stub_validation_layers
      case validation_type
      when :regex then regex_layer
      when :mx then mx_layer
      else smtp_layer
      end
    end

    def unstub_validation_layers
      allow_any_instance_of(Truemail::Validate::Regex).to receive(:match_regex_pattern?).and_call_original
      allow(Truemail::Validate::Regex).to receive(:check).and_call_original
      allow_any_instance_of(Truemail::Validate::Mx).to receive(:mx_records).and_call_original
      allow_any_instance_of(Truemail::Validate::Mx).to receive(:domain_not_include_null_mx).and_call_original
      allow_any_instance_of(Truemail::Validate::Smtp).to receive(:establish_smtp_connection).and_call_original
      allow_any_instance_of(Truemail::Validate::Smtp).to receive(:success_response?).and_call_original
      allow_any_instance_of(Truemail::Validate::Smtp).to receive(:smtp_results).and_call_original
    end

    def regex_layer
      allow_any_instance_of(Truemail::Validate::Regex).to receive(:match_regex_pattern?).and_return(success)
    end

    def mx_layer
      allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
      allow_any_instance_of(Truemail::Validate::Mx).to receive(:mx_records).and_return(mail_servers)
      allow_any_instance_of(Truemail::Validate::Mx).to receive(:domain_not_include_null_mx).and_return(success)
    end

    def request_instance
      request = Truemail::Validate::Smtp::Request.new(
        host: mail_servers.first,
        email: email,
        configuration: configuration
      )

      request.response.tap do |response|
        response.port_opened = true
        response.connection = true
        response.helo = true
        response.mailfrom = true
        response.rcptto = false
        response.errors[:rcptto] = 'user not found'
      end

      request
    end

    def smtp_layer
      allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
      allow_any_instance_of(Truemail::Validate::Mx).to receive(:mx_records).and_return(mail_servers)
      allow_any_instance_of(Truemail::Validate::Mx).to receive(:domain_not_include_null_mx).and_return(true)
      allow_any_instance_of(Truemail::Validate::Smtp).to receive(:establish_smtp_connection).and_return(true)
      return allow_any_instance_of(Truemail::Validate::Smtp).to receive(:success_response?).and_return(true) if success
      allow_any_instance_of(Truemail::Validate::Smtp).to receive(:smtp_results).and_return([request_instance])
    end

    class ValidatorFactory
      def self.call(validation_type, success, email, configuration)
        new(validation_type, success, email, configuration).build
      end

      def initialize(validation_type, success, email, configuration)
        @validation_type = validation_type
        @success = success
        @email = email
        @configuration = configuration
      end

      def build
        process_validator_params
        Truemail::Validator.new(email, with: validation_type, configuration: configuration).run
      end

      private

      attr_reader :success, :email, :configuration
      attr_accessor :validation_type

      def process_validator_params
        return unless validation_type.eql?(:whitelist)
        self.validation_type = nil
        method = success ? :whitelisted_domains : :blacklisted_domains
        domain = email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3]
        configuration.tap { |config| config.public_send(method) << domain }
      end
    end
  end
end
