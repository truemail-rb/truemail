module Truemail
  RSpec.describe ConfigurationHelper, type: :helper do
    describe '.configuration_block' do
      let(:configuration_params) { { param_1: 1, param_2: 2 } }
      let(:configuration_instance) { Struct.new(*configuration_params.keys).new }

      specify { expect(configuration_block).to be_an_instance_of(Proc) }

      before { configuration_block(configuration_params).call(configuration_instance) }

      it 'sets configuration instance attributes' do
        configuration_params.each do |attribute, value|
          expect(configuration_instance.public_send(attribute)).to eq(value)
        end
      end
    end
  end
end
