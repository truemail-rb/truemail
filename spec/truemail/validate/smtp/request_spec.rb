RSpec.describe Truemail::Validate::Smtp::Request do
  subject(:request_instance) { described_class.new(host: mail_server, email: target_email) }

  let(:mail_server)           { FFaker::Internet.domain_name }
  let(:target_email)          { FFaker::Internet.email }
  let(:response_instance)     { request_instance.response  }
  let(:request_instance_host) { request_instance.host }
  let(:configuration)         { request_instance.send(:configuration) }
  let(:connection_timout)     { configuration.connection_timeout }
  let(:response_timeout)      { configuration.response_timeout }

  before { Truemail.configure { |config| config.verifier_email = FFaker::Internet.email } }

  describe 'attribute accessors' do
    specify { expect(request_instance.members).to include(:host, :email, :response) }
  end

  describe '.new' do
    specify { expect(request_instance.host).to eq(mail_server) }
    specify { expect(request_instance.email).to eq(target_email) }
    specify { expect(response_instance).to be_an_instance_of(Truemail::Validate::Smtp::Response) }
  end

  describe '#check_port' do
    let(:connection_timeout) { configuration.connection_timeout }

    context 'when port opened' do
      specify do
        allow(Timeout).to receive(:timeout).with(connection_timeout).and_call_original
        allow(TCPSocket).to receive_message_chain(:new, :close)
        expect { request_instance.check_port }.to change(response_instance, :port_opened).from(nil).to(true)
      end
    end

    context 'when port closed' do
      specify do
        allow(Timeout).to receive(:timeout).with(connection_timeout).and_raise(Timeout::Error)
        expect { request_instance.check_port }.to change(response_instance, :port_opened).from(nil).to(false)
      end
    end
  end

  describe '#session' do
    context 'when session creates' do
      let(:session) { request_instance.send(:session) }

      before do
        allow(Net::SMTP)
          .to receive(:new)
          .with(request_instance_host, Truemail::Validate::Smtp::SMTP_PORT)
          .and_call_original
      end

      it 'sets connection timeout with value from global configuration' do
        expect(session.open_timeout).to eq(connection_timout)
      end

      it 'sets response timeout with value from global configuration' do
        expect(session.read_timeout).to eq(response_timeout)
      end
    end
  end

  describe '#run' do
    before do
      allow(session).to receive(:open_timeout=).with(connection_timout)
      allow(session).to receive(:read_timeout=).with(response_timeout)
      allow(Net::SMTP)
          .to receive(:new)
          .with(request_instance_host, Truemail::Validate::Smtp::SMTP_PORT)
          .and_return(session)
    end

    context 'when smtp communication complete successfully' do
      let(:session) do
        instance_double(
          'Net::SMTP',
          open_timeout: connection_timout,
          read_timeout: response_timeout,
          helo: true,
          mailfrom: true,
          rcptto: true
        )
      end

      specify do
        allow(session).to receive(:start).and_yield(session)

        expect { request_instance.run }
          .to change(response_instance, :connection).from(nil).to(true)
          .and change(response_instance, :helo).from(nil).to(true)
          .and change(response_instance, :mailfrom).from(nil).to(true)
          .and change(response_instance, :rcptto).from(nil).to(true)
          .and not_change(response_instance, :errors)

        expect(request_instance.run).to be(true)
      end
    end

    context 'when smtp communication fails' do
      let(:error_message) { 'error message' }
      let(:session) do
        instance_double(
          'Net::SMTP',
          open_timeout: connection_timout,
          read_timeout: response_timeout
        )
      end

      context 'when connection timeout error' do
        specify do
          allow(session).to receive(:start).and_raise(Net::OpenTimeout)

          expect { request_instance.run }
            .to change(response_instance, :connection).from(nil).to(false)
            .and change(response_instance, :errors)
            .from({}).to({ connection: Truemail::Validate::Smtp::CONNECTION_TIMEOUT_ERROR })
            .and not_change(response_instance, :helo)
            .and not_change(response_instance, :mailfrom)
            .and not_change(response_instance, :rcptto)

          expect(request_instance.run).to be(false)
        end
      end

      context 'when connection other errors' do
        specify do
          allow(session).to receive(:start).and_raise(StandardError, error_message)

          expect { request_instance.run }
            .to change(response_instance, :connection).from(nil).to(false)
            .and change(response_instance, :errors)
            .from({}).to({ connection: 'error message' })
            .and not_change(response_instance, :helo)
            .and not_change(response_instance, :mailfrom)
            .and not_change(response_instance, :rcptto)

          expect(request_instance.run).to be(false)
        end
      end

      context 'when smtp response errors' do
        it 'helo smtp server response timeout' do
          allow(session).to receive(:start).and_yield(session)
          allow(session).to receive(:helo).and_raise(Net::ReadTimeout)
          allow(session).to receive(:mailfrom)
          allow(session).to receive(:rcptto)

          expect { request_instance.run }
            .to change(response_instance, :connection).from(nil).to(true)
            .and change(response_instance, :helo).from(nil).to(false)
            .and change(response_instance, :errors)
            .from({}).to({ helo: Truemail::Validate::Smtp::RESPONSE_TIMEOUT_ERROR })
            .and not_change(response_instance, :mailfrom)
            .and not_change(response_instance, :rcptto)

          expect(session).not_to have_received(:mailfrom)
          expect(session).not_to have_received(:rcptto)

          expect(request_instance.run).to be(false)
        end

        it 'mailfrom smtp server error' do
          allow(session).to receive(:start).and_yield(session)
          allow(session).to receive(:helo).and_return(true)
          allow(session).to receive(:mailfrom).and_raise(StandardError, error_message)
          allow(session).to receive(:rcptto)

          expect { request_instance.run }
            .to change(response_instance, :connection).from(nil).to(true)
            .and change(response_instance, :helo).from(nil).to(true)
            .and change(response_instance, :mailfrom).from(nil).to(false)
            .and change(response_instance, :errors).from({}).to({ mailfrom: error_message })
            .and not_change(response_instance, :rcptto)

          expect(session).not_to have_received(:rcptto)

          expect(request_instance.run).to be(false)
        end

        it 'rcptto smtp server error' do
          allow(session).to receive(:start).and_yield(session)
          allow(session).to receive(:helo).and_return(true)
          allow(session).to receive(:mailfrom).and_return(true)
          allow(session).to receive(:rcptto).and_raise(StandardError, error_message)

          expect { request_instance.run }
            .to change(response_instance, :connection).from(nil).to(true)
            .and change(response_instance, :helo).from(nil).to(true)
            .and change(response_instance, :mailfrom).from(nil).to(true)
            .and change(response_instance, :rcptto).from(nil).to(false)
            .and change(response_instance, :errors).from({}).to({ rcptto: error_message })

          expect(request_instance.run).to be(false)
        end
      end
    end
  end
end
