# frozen_string_literal: true

RSpec.describe Truemail::Wrapper do
  let(:email) { FFaker::Internet.email }
  let(:method) { :hosts_from_mx_records? }
  let(:mx_instance) { instance_double(Truemail::Validate::Mx, method => true) }
  let(:block) { ->(_) { mx_instance.send(method) } }

  before { Truemail.configure { |config| config.verifier_email = email } }

  describe '.call' do
    subject(:resolver_execution_wrapper) { resolver_execution_wrapper_instance.call(&block) }

    let(:resolver_execution_wrapper_instance) { described_class.new }

    before { allow(resolver_execution_wrapper_instance).to receive(:call).and_call_original }

    context 'when not raises exception' do
      specify do
        allow(mx_instance).to receive(method).and_return(true)
        expect(resolver_execution_wrapper).to be(true)
      end

      specify do
        allow(mx_instance).to receive(method).and_return(false)
        expect(resolver_execution_wrapper).to be(false)
      end
    end

    context 'when raises exception' do
      context 'with Resolv::ResolvError exception' do
        specify do
          allow(mx_instance).to receive(method).and_raise(Resolv::ResolvError)
          expect(resolver_execution_wrapper).to be(false)
        end
      end

      context 'with IPAddr::InvalidAddressError exception' do
        specify do
          allow(mx_instance).to receive(method).and_raise(IPAddr::InvalidAddressError)
          expect(resolver_execution_wrapper).to be(false)
        end
      end

      context 'with Timeout::Error exception' do
        specify do
          allow(mx_instance).to receive(method).and_raise(Timeout::Error)

          expect { resolver_execution_wrapper }
            .to change(resolver_execution_wrapper_instance, :attempts).from(2).to(0)

          expect(resolver_execution_wrapper).to be(false)
        end
      end
    end
  end
end
