# frozen_string_literal: true

RSpec.describe Truemail::Dns::Resolver do
  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:WORKER_ACTIONS) }
  end

  described_class::WORKER_ACTIONS.each do |method|
    describe ".#{method}" do
      subject(:worker_action) do
        described_class.public_send(method, argument, configuration: configuration_instance)
      end

      let(:argument) { 'some_argument' }
      let(:configuration_instance) { create_configuration }
      let(:dns_resolver_worker_instance) { instance_double('DnsResolverWorker') }

      specify "creates Truemail::DnsResolver::Worker##{method}" do
        expect(Truemail::Dns::Worker)
          .to receive(:new)
          .with(configuration_instance.dns)
          .and_return(dns_resolver_worker_instance)
        expect(dns_resolver_worker_instance).to receive(method).with(argument)
        worker_action
      end
    end
  end
end
