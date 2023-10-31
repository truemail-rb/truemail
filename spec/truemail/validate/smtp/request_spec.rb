# frozen_string_literal: true

RSpec.describe Truemail::Validate::Smtp::Request do
  subject(:request_instance) do
    described_class.new(
      configuration: configuration_instance,
      host: mail_server,
      email: target_email,
      port_open_status: port_open_status,
      **attempts
    )
  end

  let(:mail_server)            { random_domain_name }
  let(:target_email)           { random_email }
  let(:response_instance)      { request_instance.response }
  let(:request_instance_host)  { request_instance.host }
  let(:configuration_instance) { create_configuration }
  let(:smtp_port)              { configuration_instance.smtp_port }
  let(:connection_timeout)     { configuration_instance.connection_timeout }
  let(:response_timeout)       { configuration_instance.response_timeout }
  let(:verifier_domain)        { configuration_instance.verifier_domain }
  let(:attempts)               { {} }
  let(:port_open_status)       { proc { true } }

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:CONNECTION_TIMEOUT_ERROR) }
    specify { expect(described_class).to be_const_defined(:RESPONSE_TIMEOUT_ERROR) }
    specify { expect(described_class).to be_const_defined(:CONNECTION_DROPPED) }
  end

  describe 'attribute readers' do
    specify { expect(request_instance.public_methods).to include(:configuration, :host, :email, :response) }
  end

  describe '.new' do
    specify { expect(request_instance.configuration).to be_an_instance_of(Truemail::Validate::Smtp::Request::Configuration) }
    specify { expect(request_instance.host).to eq(mail_server) }
    specify { expect(request_instance.email).to eq(target_email) }
    specify { expect(request_instance.response).to be_an_instance_of(Truemail::Validate::Smtp::Response) }
  end

  describe '#check_port' do
    let(:response_instance_target_method) { request_instance.check_port }

    context 'when port opened' do
      specify do
        allow(::Socket).to receive(:tcp)
          .with(
            request_instance_host,
            smtp_port,
            connect_timeout: connection_timeout
          ) { |&block| expect(block).to eq(port_open_status) }
          .and_return(true)
        expect { request_instance.check_port }
          .to change(response_instance, :port_opened).from(nil).to(true)
      end
    end

    context 'when port closed' do
      let(:error_stubs) do
        allow(::Socket).to receive(:tcp)
          .with(
            request_instance_host,
            smtp_port,
            connect_timeout: connection_timeout
          )
          .and_raise(::Errno::ETIMEDOUT)
      end

      specify do
        error_stubs
        expect { response_instance_target_method }.to change(response_instance, :port_opened).from(nil).to(false)
      end

      include_examples 'request retry behavior'
    end
  end

  describe '#session' do
    context 'when session creates' do
      let(:session_net_smtp) { request_instance.send(:session).send(:net_smtp) }

      before do
        allow(Truemail::Validate::Smtp::Request::Session)
          .to receive(:new)
          .with(request_instance_host, smtp_port, connection_timeout, response_timeout)
          .and_call_original
      end

      it 'sets SMTP port number with value from global configuration' do
        expect(session_net_smtp.port).to eq(smtp_port)
      end

      it 'sets connection timeout with value from global configuration' do
        expect(session_net_smtp.open_timeout).to eq(connection_timeout)
      end

      it 'sets response timeout with value from global configuration' do
        expect(session_net_smtp.read_timeout).to eq(response_timeout)
      end
    end
  end

  describe '#run' do
    let(:response_instance_target_method) { request_instance.run }

    before do
      allow(Truemail::Validate::Smtp::Request::Session)
        .to receive(:new)
        .with(request_instance_host, smtp_port, connection_timeout, response_timeout)
        .and_return(session)
    end

    context 'when smtp communication complete successfully' do
      let(:session) do
        instance_double(
          'Net::SMTP',
          open_timeout: connection_timeout,
          read_timeout: response_timeout,
          helo: true,
          mailfrom: true,
          rcptto: true
        )
      end

      specify do
        allow(session).to receive(:start).with(verifier_domain).and_yield(session)

        expect { response_instance_target_method }
          .to change(response_instance, :connection)
          .from(nil).to(true)
          .and change(response_instance, :helo)
          .from(nil).to(true)
          .and change(response_instance, :mailfrom)
          .from(nil).to(true)
          .and change(response_instance, :rcptto)
          .from(nil).to(true)
          .and not_change(response_instance, :errors)

        expect(response_instance_target_method).to be(true)
      end
    end

    context 'when smtp communication fails' do
      let(:error_message) { 'error message' }
      let(:session) do
        instance_double(
          'Net::SMTP',
          open_timeout: connection_timeout,
          read_timeout: response_timeout
        )
      end

      context 'when open connection timeout error' do
        let(:error_stubs) do
          allow(session).to receive(:start).with(verifier_domain).and_raise(::Net::OpenTimeout)
        end

        specify do
          error_stubs

          expect { response_instance_target_method }
            .to change(response_instance, :connection)
            .from(nil).to(false)
            .and change(response_instance, :errors)
            .from({}).to(connection: Truemail::Validate::Smtp::Request::CONNECTION_TIMEOUT_ERROR)
            .and not_change(response_instance, :helo)
            .and not_change(response_instance, :mailfrom)
            .and not_change(response_instance, :rcptto)

          expect(response_instance_target_method).to be(false)
        end

        include_examples 'request retry behavior'
      end

      context 'when read connection timeout error' do
        let(:error_stubs) do
          allow(session).to receive(:start).with(verifier_domain).and_raise(::Net::ReadTimeout)
        end

        specify do
          error_stubs

          expect { response_instance_target_method }
            .to change(response_instance, :connection)
            .from(nil).to(false)
            .and change(response_instance, :errors)
            .from({}).to(connection: Truemail::Validate::Smtp::Request::RESPONSE_TIMEOUT_ERROR)
            .and not_change(response_instance, :helo)
            .and not_change(response_instance, :mailfrom)
            .and not_change(response_instance, :rcptto)

          expect(response_instance_target_method).to be(false)
        end

        include_examples 'request retry behavior'
      end

      context 'when remote server has dropped connection during session' do
        let(:error_stubs) do
          allow(session).to receive(:start).with(verifier_domain).and_yield(session).and_raise(::EOFError)
          allow(session).to receive(:mailfrom).and_raise(::StandardError)
        end

        specify do
          error_stubs

          expect { response_instance_target_method }
            .to change(response_instance, :connection)
            .from(nil).to(false)
            .and change(response_instance, :helo)
            .from(nil).to(true)
            .and change(response_instance, :errors)
            .from({}).to(connection: Truemail::Validate::Smtp::Request::CONNECTION_DROPPED, mailfrom: 'StandardError')
            .and change(response_instance, :mailfrom)
            .from(nil).to(false)
            .and not_change(response_instance, :rcptto)

          expect(response_instance_target_method).to be(false)
        end

        include_examples 'request retry behavior'
      end

      context 'when connection other errors' do
        let(:error_stubs) do
          allow(session).to receive(:start).with(verifier_domain).and_raise(::StandardError, error_message)
        end

        specify do
          error_stubs

          expect { response_instance_target_method }
            .to change(response_instance, :connection)
            .from(nil).to(false)
            .and change(response_instance, :errors)
            .from({}).to(connection: 'error message')
            .and not_change(response_instance, :helo)
            .and not_change(response_instance, :mailfrom)
            .and not_change(response_instance, :rcptto)

          expect(response_instance_target_method).to be(false)
        end

        include_examples 'request retry behavior'
      end

      context 'when smtp response errors' do
        it 'mailfrom smtp server error' do
          allow(session).to receive(:start).with(verifier_domain).and_yield(session)
          allow(session).to receive(:helo).and_return(true)
          allow(session).to receive(:mailfrom).and_raise(::StandardError, error_message)
          allow(session).to receive(:rcptto)

          expect { response_instance_target_method }
            .to change(response_instance, :connection)
            .from(nil).to(true)
            .and change(response_instance, :helo)
            .from(nil).to(true)
            .and change(response_instance, :mailfrom)
            .from(nil).to(false)
            .and change(response_instance, :errors)
            .from({}).to(mailfrom: error_message)
            .and not_change(response_instance, :rcptto)

          expect(session).not_to have_received(:rcptto)

          expect(response_instance_target_method).to be(false)
        end

        it 'rcptto smtp server error' do
          allow(session).to receive(:start).with(verifier_domain).and_yield(session)
          allow(session).to receive_messages(helo: true, mailfrom: true)
          allow(session).to receive(:rcptto).and_raise(::StandardError, error_message)

          expect { response_instance_target_method }
            .to change(response_instance, :connection)
            .from(nil).to(true)
            .and change(response_instance, :helo)
            .from(nil).to(true)
            .and change(response_instance, :mailfrom)
            .from(nil).to(true)
            .and change(response_instance, :rcptto)
            .from(nil).to(false)
            .and change(response_instance, :errors)
            .from({}).to(rcptto: error_message)

          expect(response_instance_target_method).to be(false)
        end
      end
    end
  end
end

RSpec.describe Truemail::Validate::Smtp::Request::Configuration do
  subject(:request_configuration_instance) { described_class.new(configuration_instance) }

  let(:configuration_instance) { create_configuration }

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:REQUEST_PARAMS) }
  end

  describe 'attribute readers' do
    let(:attribute_readers) { %i[smtp_port connection_timeout response_timeout verifier_domain verifier_email] }

    specify { expect(request_configuration_instance.public_methods).to include(*attribute_readers) }
  end

  describe '.new' do
    Truemail::Validate::Smtp::Request::Configuration::REQUEST_PARAMS.each do |method|
      specify do
        expect(request_configuration_instance.public_send(method)).to eq(configuration_instance.public_send(method))
      end
    end
  end
end

RSpec.describe Truemail::Validate::Smtp::Request::Session do
  subject(:request_session_instance) { described_class.new(host, port, connection_timeout, response_timeout) }

  let(:host) { random_domain_name }
  let(:port) { 42 }
  let(:connection_timeout) { 13 }
  let(:response_timeout) { 14 }
  let(:net_smtp_instance) { ::Struct.new(:open_timeout, :read_timeout, :tls_verify).new }

  describe '.new' do
    subject(:request_net_smtp_instance) { request_session_instance.send(:net_smtp) }

    context 'when undefined Net::SMTP version' do
      it 'creates session instance with net smtp instance inside' do
        expect(::Net::SMTP).to receive(:const_defined?).with(:VERSION).and_return(false)
        expect(::Net::SMTP).to receive(:new).with(host, port).and_return(net_smtp_instance)
        expect(request_net_smtp_instance.open_timeout).to eq(connection_timeout)
        expect(request_net_smtp_instance.read_timeout).to eq(response_timeout)
      end
    end

    context 'when Net::SMTP version < 0.3.0' do
      it 'creates session instance with net smtp instance inside' do
        stub_const('Net::SMTP::VERSION', '0.2.128506')
        expect(::Net::SMTP).to receive(:new).with(host, port).and_return(net_smtp_instance)
        expect(request_net_smtp_instance.open_timeout).to eq(connection_timeout)
        expect(request_net_smtp_instance.read_timeout).to eq(response_timeout)
      end
    end

    context 'when Net::SMTP version >= 0.3.0' do
      it 'creates session instance with net smtp instance inside' do
        stub_const('Net::SMTP::VERSION', '0.3.0')
        expect(::Net::SMTP).to receive(:new).with(host, port, tls_verify: false).and_return(net_smtp_instance)
        expect(request_net_smtp_instance.open_timeout).to eq(connection_timeout)
        expect(request_net_smtp_instance.read_timeout).to eq(response_timeout)
      end
    end
  end

  describe '#start' do
    subject(:session_start) { request_session_instance.start(helo_domain, &session_actions) }

    let(:helo_domain) { random_domain_name }
    let(:session_actions) { proc {} }

    context 'when undefined Net::SMTP version' do
      before do
        allow(::Net::SMTP).to receive(:const_defined?).with(:VERSION).and_return(false)
        allow(::Net::SMTP).to receive(:new).with(host, port).and_return(net_smtp_instance)
      end

      it 'passes helo domain as position argument' do
        expect(net_smtp_instance).to receive(:start).with(helo_domain, &session_actions)
        session_start
      end
    end

    context 'when Net::SMTP version in range 0.1.0...0.2.0' do
      before do
        stub_const('Net::SMTP::VERSION', '0.1.314')
        allow(::Net::SMTP).to receive(:new).with(host, port).and_return(net_smtp_instance)
      end

      it 'passes helo domain as position argument' do
        expect(net_smtp_instance).to receive(:start).with(helo_domain, &session_actions)
        session_start
      end
    end

    context 'when Net::SMTP version in range 0.2.0...0.3.0' do
      before do
        stub_const('Net::SMTP::VERSION', '0.2.128506')
        allow(::Net::SMTP).to receive(:new).with(host, port).and_return(net_smtp_instance)
      end

      it 'passes helo domain as position argument' do
        expect(net_smtp_instance).to receive(:start).with(helo_domain, tls_verify: false, &session_actions)
        session_start
      end
    end

    context 'when Net::SMTP version >= 0.3.0' do
      before do
        stub_const('Net::SMTP::VERSION', '0.3.0')
        allow(::Net::SMTP).to receive(:new).with(host, port, tls_verify: false).and_return(net_smtp_instance)
      end

      it 'passes helo domain as keyword argument' do
        expect(net_smtp_instance).to receive(:start).with(helo: helo_domain, &session_actions)
        session_start
      end
    end
  end
end
