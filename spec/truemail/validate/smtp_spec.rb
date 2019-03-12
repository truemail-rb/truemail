RSpec.describe Truemail::Validate::Smtp do
  let(:email) { FFaker::Internet.email }

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:RESPONSE_ATTRS) }
    specify { expect(described_class).to be_const_defined(:SMTP_PORT) }
    specify { expect(described_class).to be_const_defined(:CONNECTION_TIMEOUT_ERROR) }
    specify { expect(described_class).to be_const_defined(:RESPONSE_TIMEOUT_ERROR) }
    specify { expect(described_class).to be_const_defined(:Response) }
    specify { expect(described_class).to be_const_defined(:Request) }
  end

  describe 'instance methods' do
    subject(:smtp_validator_instance) do
      described_class.new(
        Truemail::Validator::Result.new(
          email: email,
          mail_servers: Array.new(3) { FFaker::Internet.domain_name }
        )
      )
    end

    let(:result_instance) { smtp_validator_instance.result }
    let(:smtp_results) { smtp_validator_instance.smtp_results }

    describe '#request' do
      before { smtp_results.push(*(0..42)) }

      it 'returns last smtp result' do
        expect(smtp_validator_instance.send(:request)).to eq(42)
      end
    end

    describe '#establish_smtp_connection' do
      before { allow(result_instance.mail_servers).to receive(:each).and_call_original }

      context 'until request port check fails' do
        it 'creates smtp request instances' do
          allow_any_instance_of(Truemail::Validate::Smtp::Request).to receive(:check_port).and_return(false)
          allow(Truemail::Validate::Smtp::Request).to receive(:new).and_call_original

          expect { smtp_validator_instance.send(:establish_smtp_connection) }
            .to change(smtp_results, :size)
            .from(0).to(result_instance.mail_servers.size)
        end
      end

      context 'until request run fails' do
        it 'creates smtp request instances' do
          allow_any_instance_of(Truemail::Validate::Smtp::Request).to receive(:check_port).and_return(true)
          allow_any_instance_of(Truemail::Validate::Smtp::Request).to receive(:run).and_return(false)

          expect { smtp_validator_instance.send(:establish_smtp_connection) }
            .to change(smtp_results, :size)
            .from(0).to(result_instance.mail_servers.size)
        end
      end

      context 'when request port check run completed successfully' do
        it 'stops creating smtp request instances' do
          allow_any_instance_of(Truemail::Validate::Smtp::Request).to receive(:check_port).and_return(true)
          allow_any_instance_of(Truemail::Validate::Smtp::Request).to receive(:run).and_return(true)

          expect { smtp_validator_instance.send(:establish_smtp_connection) }
            .to change(smtp_results, :size).from(0).to(1)

          expect(smtp_results.last.host).to eq(result_instance.mail_servers.first)
        end
      end
    end

    describe '#run' do
      before do
        allow(Truemail::Validate::Mx).to receive(:check).and_return(true)
        allow(result_instance.mail_servers).to receive(:each)
        result_instance.success = true
      end

      context 'when smtp validation has success response' do
        before do
          request = Truemail::Validate::Smtp::Request.new(
            host: result_instance.mail_servers.first, email: result_instance.email
          )

          request.response.rcptto = true
          smtp_results << request
        end

        specify do
          allow(result_instance.mail_servers).to receive(:each)

          expect { smtp_validator_instance.run }
            .to not_change(result_instance, :success)
            .and not_change(result_instance, :errors)
        end

        it 'returns true' do
          expect(smtp_validator_instance.run).to be(true)
        end
      end

      context 'when smtp validation has only failed attempts' do
        before do
          request_1 = Truemail::Validate::Smtp::Request.new(
            host: result_instance.mail_servers[0], email: result_instance.email
          )
          request_1.response.port_opened = false

          request_2 = Truemail::Validate::Smtp::Request.new(
            host: result_instance.mail_servers[1], email: result_instance.email
          )
          request_2.response.tap do |response|
            response.port_opened = true
            response.connection = false
            response.errors[:connection] = 'connection error'
          end

          request_3 = Truemail::Validate::Smtp::Request.new(
            host: result_instance.mail_servers[2], email: result_instance.email
          )

          request_3.response.tap do |response|
            response.port_opened = true
            response.connection = true
            response.helo = true
            response.mailfrom = true
            response.rcptto = false
            response.errors[:rcptto] = 'smtp error'
          end

          smtp_results.push(request_1, request_2, request_3)
        end

        specify do
          allow(result_instance.mail_servers).to receive(:each)

          expect { smtp_validator_instance.run }
            .to change(result_instance, :success).from(true).to(false)
            .and change(result_instance, :errors).from({}).to({ smtp: Truemail::Validate::Smtp::ERROR })
            .and change(result_instance, :smtp_debug).from(nil).to(smtp_results)
        end

        it 'returns false' do
          expect(smtp_validator_instance.run).to be(false)
        end
      end
    end
  end
end
