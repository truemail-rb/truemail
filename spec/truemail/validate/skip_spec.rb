# frozen_string_literal: true

RSpec.describe Truemail::Validate::Skip do
  describe '.check' do
    subject(:skip_validator) { described_class.check(result_instance) }

    let(:result_instance) { Truemail::Validator::Result.new(email: FFaker::Internet.email) }

    specify do
      expect { skip_validator }.to change(result_instance, :success).from(nil).to(true)
    end

    it 'returns true' do
      expect(skip_validator).to be(true)
    end
  end
end
