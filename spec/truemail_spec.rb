module Truemail
  RSpec.describe Truemail do
    specify { expect(subject).to be_const_defined(:VERSION) }
    specify { expect(subject).to be_const_defined(:Error) }
    specify { expect(subject).to be_const_defined(:Configuration) }
    specify { expect(subject).to be_const_defined(:ConfigurationError) }

    describe '.configure' do
      subject(:configure) { described_class.configure(&config_block) }
      let(:config_block) {}

      context 'without block' do
        specify { expect(configure).to be_nil }
        specify { expect { configure }.not_to change(described_class, :configuration) }
      end

      context 'with block' do
        context 'without required parameter' do
          let(:config_block) { configuration_block }

          specify { expect { configure }.to raise_error(ConfigurationError, Error::CONFIGURATION_INCOMPLETE) }
        end

        context 'with valid required parameter' do
          let(:email) { 'some_email@subdomain.domain.zone' }
          let(:config_block) { configuration_block(verifier_email: email) }

          specify do
            expect(configure).to be_an_instance_of(Configuration)
            expect(described_class.configuration.verifier_email).to eq(email)
          end
        end
      end
    end
  end
end
