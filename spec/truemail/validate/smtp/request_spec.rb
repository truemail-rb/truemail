# frozen_string_literal: true

RSpec.describe Truemail::Validate::Smtp::Request do
  subject(:request_instance) do
    described_class.new(
      configuration: configuration_instance,
      host: mail_server,
      email: target_email,
      **attempts
    )
  end

  let(:mail_server)            { FFaker::Internet.domain_name }
  let(:target_email)           { FFaker::Internet.email }
  let(:response_instance)      { request_instance.response }
  let(:request_instance_host)  { request_instance.host }
  let(:configuration_instance) { create_configuration }
  let(:connection_timeout)     { configuration_instance.connection_timeout }
  let(:response_timeout)       { configuration_instance.response_timeout }
  let(:attempts)               { {} }

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:SMTP_PORT) }
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
        allow(Timeout).to receive(:timeout).with(connection_timeout).and_call_original
        allow(TCPSocket).to receive_message_chain(:new, :close)
        expect { request_instance.check_port }
          .to change(response_instance, :port_opened).from(nil).to(true)
      end
    end

    context 'when port closed' do
      let(:error_stubs) do
        allow(Timeout).to receive(:timeout).with(connection_timeout).and_raise(Timeout::Error)
      end

      specify do
        error_stubs
        expect { response_instance_target_method }.to change(response_instance, :port_opened).from(nil).to(false)
      end

      specify do
        allow(TCPSocket).to receive(:new).and_raise(SocketError)
        expect { response_instance_target_method }.to change(response_instance, :port_opened).from(nil).to(false)
      end

      include_examples 'request retry behavior'
    end
  end

  describe '#session' do
    context 'when session creates' do
      let(:session) { request_instance.send(:session) }

      before do
        allow(Net::SMTP)
          .to receive(:new)
          .with(request_instance_host, Truemail::Validate::Smtp::Request::SMTP_PORT)
          .and_call_original
      end

      it 'sets connection timeout with value from global configuration' do
        expect(session.open_timeout).to eq(connection_timeout)
      end

      it 'sets response timeout with value from global configuration' do
        expect(session.read_timeout).to eq(response_timeout)
      end
    end
  end

  describe '#run' do
    let(:response_instance_target_method) { request_instance.run }

    before do
      allow(session).to receive(:open_timeout=).with(connection_timeout)
      allow(session).to receive(:read_timeout=).with(response_timeout)
      allow(Net::SMTP)
        .to receive(:new)
        .with(request_instance_host, Truemail::Validate::Smtp::Request::SMTP_PORT)
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
        allow(session).to receive(:start).and_yield(session)

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

      context 'when connection timeout error' do
        let(:error_stubs) do
          allow(session).to receive(:start).and_raise(Net::OpenTimeout)
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

      context 'when remote server has dropped connection during session' do
        let(:error_stubs) do
          allow(session).to receive(:start).and_yield(session).and_raise(EOFError)
          allow(session).to receive(:mailfrom).and_raise(StandardError)
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
          allow(session).to receive(:start).and_raise(StandardError, error_message)
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
          allow(session).to receive(:start).and_yield(session)
          allow(session).to receive(:helo).and_return(true)
          allow(session).to receive(:mailfrom).and_raise(StandardError, error_message)
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
          allow(session).to receive(:start).and_yield(session)
          allow(session).to receive(:helo).and_return(true)
          allow(session).to receive(:mailfrom).and_return(true)
          allow(session).to receive(:rcptto).and_raise(StandardError, error_message)

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
    let(:attribute_readers) { %i[connection_timeout response_timeout verifier_domain verifier_email] }

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
