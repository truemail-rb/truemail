# frozen_string_literal: true

RSpec.describe Truemail::Validate::Smtp do
  let(:email) { FFaker::Internet.email }
  let(:configuration_instance) { create_configuration }

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:ERROR) }
    specify { expect(described_class).to be_const_defined(:RESPONSE_ATTRS) }
    specify { expect(described_class).to be_const_defined(:Response) }
    specify { expect(described_class).to be_const_defined(:Request) }
  end

  describe 'inheritance' do
    specify { expect(described_class).to be < Truemail::Validate::Base }
  end

  describe 'instance methods' do
    subject(:smtp_validator_instance) do
      described_class.new(
        Truemail::Validator::Result.new(
          email: email,
          mail_servers: Array.new(3) { FFaker::Internet.ip_v4_address },
          configuration: configuration_instance
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

    describe '#mail_servers' do
      it 'returns mail servers from result instance' do
        expect(smtp_validator_instance.send(:mail_servers)).to eq(result_instance.mail_servers)
      end
    end

    describe '#attempts' do
      shared_examples 'returns empty hash' do
        it 'returns empty hash' do
          expect(smtp_validator_instance.send(:attempts)).to eq({})
        end
      end

      context 'when more then one mail server' do
        include_examples 'returns empty hash'
      end

      context 'when one mail server' do
        before { allow(result_instance.mail_servers).to receive(:one?).and_return(true) }

        it 'returns hash with attempts from configuration' do
          expect(smtp_validator_instance.send(:attempts)).to eq(attempts: configuration_instance.connection_attempts)
        end
      end

      context 'when smtp fail fast enabled' do
        before { configuration_instance.smtp_fail_fast = true }

        include_examples 'returns empty hash'
      end
    end

    describe '#establish_smtp_connection' do
      before { allow(result_instance.mail_servers).to receive(:each).and_call_original }

      context 'when establishment smtp connection fails' do
        context 'when smtp fail fast disabled' do
          context 'until request port check fails' do
            it 'creates smtp request instances' do
              allow_any_instance_of(Truemail::Validate::Smtp::Request).to receive(:check_port).and_return(false)
              allow(Truemail::Validate::Smtp::Request).to receive(:new).and_call_original

              expect(result_instance)
                .to receive(:punycode_email).exactly(result_instance.mail_servers.size).and_call_original
              expect { smtp_validator_instance.send(:establish_smtp_connection) }
                .to change(smtp_results, :size)
                .from(0).to(result_instance.mail_servers.size)

              expect(smtp_results.map(&:host)).to eq(result_instance.mail_servers)
            end
          end

          context 'until request run fails' do
            it 'creates smtp request instances' do
              allow_any_instance_of(Truemail::Validate::Smtp::Request).to receive(:check_port).and_return(true)
              allow_any_instance_of(Truemail::Validate::Smtp::Request).to receive(:run).and_return(false)

              expect { smtp_validator_instance.send(:establish_smtp_connection) }
                .to change(smtp_results, :size)
                .from(0).to(result_instance.mail_servers.size)

              expect(smtp_results.map(&:host)).to eq(result_instance.mail_servers)
            end
          end

          context 'until request run, rcptto_error fails' do
            it 'creates only one smtp request instance' do
              allow_any_instance_of(Truemail::Validate::Smtp::Request).to receive(:check_port).and_return(true)
              allow_any_instance_of(Truemail::Validate::Smtp::Request).to receive(:run).and_return(false)
              allow_any_instance_of(Truemail::Validate::Smtp::Response).to receive(:errors).and_return(rcptto: 'error')

              expect { smtp_validator_instance.send(:establish_smtp_connection) }
                .to change(smtp_results, :size)
                .from(0).to(1)

              expect(smtp_results.last.send(:host)).to eq(result_instance.mail_servers.first)
            end
          end
        end

        context 'when smtp fail fast enabled' do
          before { configuration_instance.smtp_fail_fast = true }

          context 'until request port check fails' do
            it 'creates only one smtp request instance' do
              allow_any_instance_of(Truemail::Validate::Smtp::Request).to receive(:check_port).and_return(false)
              allow(Truemail::Validate::Smtp::Request).to receive(:new).and_call_original

              expect(result_instance).to receive(:punycode_email).exactly(1).and_call_original
              expect { smtp_validator_instance.send(:establish_smtp_connection) }
                .to change(smtp_results, :size)
                .from(0).to(1)

              expect(smtp_results.last.send(:host)).to eq(result_instance.mail_servers.first)
            end
          end

          context 'until request run fails, smtp fail fast enabled' do
            it 'creates only one smtp request instance' do
              allow_any_instance_of(Truemail::Validate::Smtp::Request).to receive(:check_port).and_return(true)
              allow_any_instance_of(Truemail::Validate::Smtp::Request).to receive(:run).and_return(false)

              expect { smtp_validator_instance.send(:establish_smtp_connection) }
                .to change(smtp_results, :size)
                .from(0).to(1)

              expect(smtp_results.last.send(:host)).to eq(result_instance.mail_servers.first)
            end
          end
        end
      end

      context 'when establishment smtp connection successful' do
        context 'when request port check run completed successfully' do
          it 'creates only one smtp request instance' do
            allow_any_instance_of(Truemail::Validate::Smtp::Request).to receive(:check_port).and_return(true)
            allow_any_instance_of(Truemail::Validate::Smtp::Request).to receive(:run).and_return(true)

            expect(result_instance).to receive(:punycode_email).exactly(1).and_call_original
            expect { smtp_validator_instance.send(:establish_smtp_connection) }
              .to change(smtp_results, :size).from(0).to(1)

            expect(smtp_results.last.send(:host)).to eq(result_instance.mail_servers.first)
          end
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
            host: result_instance.mail_servers.first,
            email: result_instance.email,
            configuration: configuration_instance
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
        let(:smtp_error_context_1) { 'smtp error' }
        let(:smtp_error_context_2) { 'smtp error' }

        before do
          request_1 = Truemail::Validate::Smtp::Request.new(
            host: result_instance.mail_servers[0],
            email: result_instance.email,
            configuration: configuration_instance
          )
          request_1.response.port_opened = false

          request_2 = Truemail::Validate::Smtp::Request.new(
            host: result_instance.mail_servers[1],
            email: result_instance.email,
            configuration: configuration_instance
          )
          request_2.response.tap do |response|
            response.port_opened = true
            response.connection = false
            response.errors[:connection] = 'connection error'
          end

          request_3 = Truemail::Validate::Smtp::Request.new(
            host: result_instance.mail_servers[2],
            email: result_instance.email,
            configuration: configuration_instance
          )

          request_3.response.tap do |response|
            response.port_opened = true
            response.connection = true
            response.helo = true
            response.mailfrom = false
            response.errors[:mailfrom] = smtp_error_context_1
            response.rcptto = false
            response.errors[:rcptto] = smtp_error_context_2
          end

          smtp_results.push(request_1, request_2, request_3)
        end

        context 'wihout smtp safe check' do
          specify do
            allow(result_instance.mail_servers).to receive(:each)

            expect { smtp_validator_instance.run }
              .to change(result_instance, :success)
              .from(true).to(false)
              .and change(result_instance, :errors)
              .from({}).to(smtp: Truemail::Validate::Smtp::ERROR)
              .and change(result_instance, :smtp_debug)
              .from(nil).to(smtp_results)
          end

          it 'returns false' do
            expect(smtp_validator_instance.run).to be(false)
          end
        end

        context 'with smtp safe check' do
          before { configuration_instance.smtp_safe_check = true }

          context 'when smtp user error has been not detected' do
            specify do
              allow(result_instance.mail_servers).to receive(:each)

              expect { smtp_validator_instance.run }
                .to not_change(result_instance, :success)
                .and not_change(result_instance, :errors)
                .and change(result_instance, :smtp_debug).from(nil).to(smtp_results)
            end

            it 'returns false' do
              expect(smtp_validator_instance.run).to be(true)
            end
          end

          context 'when smtp user error has been detected' do
            let(:smtp_error_context) { 'some 550 error with user or account in body' }

            context 'with error in rcptto response' do
              let(:smtp_error_context_2) { smtp_error_context }

              specify do
                allow(result_instance.mail_servers).to receive(:each)

                expect { smtp_validator_instance.run }
                  .to change(result_instance, :success)
                  .from(true).to(false)
                  .and change(result_instance, :errors)
                  .from({}).to(smtp: Truemail::Validate::Smtp::ERROR)
                  .and change(result_instance, :smtp_debug)
                  .from(nil).to(smtp_results)
              end

              it 'returns false' do
                expect(smtp_validator_instance.run).to be(false)
              end
            end

            context 'with error in others smtp responses' do
              context 'with error in rcptto response' do
                let(:smtp_error_context_1) { smtp_error_context }

                specify do
                  allow(result_instance.mail_servers).to receive(:each)

                  expect { smtp_validator_instance.run }
                    .to not_change(result_instance, :success)
                    .and not_change(result_instance, :errors)
                    .and change(result_instance, :smtp_debug).from(nil).to(smtp_results)
                end

                it 'returns false' do
                  expect(smtp_validator_instance.run).to be(true)
                end
              end
            end
          end
        end
      end
    end
  end
end
