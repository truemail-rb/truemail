module Truemail
  RSpec.shared_examples 'raises argument error' do
    let(:invalid_argument) { "not_valid_#{setter}".tr('=', '') }

    specify do
      expect { configuration_instance.public_send(setter, invalid_argument) }
        .to raise_error(Truemail::ArgumentError, "#{invalid_argument} is not a valid #{setter}")
    end

    specify do
      expect { configuration_instance.public_send(setter, -1) }
        .to raise_error(Truemail::ArgumentError, "-1 is not a valid #{setter}")
    end
  end
end
