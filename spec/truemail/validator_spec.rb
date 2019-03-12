module Truemail
  RSpec.describe Truemail::Validator do
    subject(:validator_instance) { described_class.new(email, options) }

    let(:email) { FFaker::Internet.email }
    let(:options) { {} }
    let(:validator_instance_result) { validator_instance.result }

    describe 'defined constants' do
      specify { expect(described_class).to be_const_defined(:RESULT_ATTRS) }
      specify { expect(described_class).to be_const_defined(:VALIDATION_TYPES) }
      specify { expect(described_class).to be_const_defined(:Result) }
    end

    describe '.new' do
      Truemail::Validator::VALIDATION_TYPES.each do |validation_type|
        context "with: #{validation_type}" do
          let(:options) { { with: validation_type } }

          it "creates validator instance with #{validation_type} validation type" do
            expect(validator_instance.validation_type).to eq(validation_type)
          end

          it 'creates default validator result' do
            expect(validator_instance_result).to be_an_instance_of(Truemail::Validator::Result)
            expect(validator_instance_result.success).to be_nil
            expect(validator_instance_result.email).to eq(email)
            expect(validator_instance_result.domain).to be_nil
            expect(validator_instance_result.mail_servers).to eq([])
            expect(validator_instance_result.errors).to eq({})
          end
        end
      end

      context 'with invalid validation type' do
        let(:options) { { with: :invalid_validation_type } }

        specify do
          expect { validator_instance }
            .to raise_error(Truemail::ArgumentError, "#{options[:with]} is not a valid argument")
        end
      end
    end

    describe '#run' do
      subject(:validator_instance) { described_class.new(email, with: validation_type).run }

      let(:validation_type) { :regex }

      it 'calls predefined validation class' do
        allow(Truemail::Validate::Regex).to receive(:check).and_return(true)
        expect(validator_instance).to be_an_instance_of(Truemail::Validator)
        expect(Truemail::Validate::Regex).to have_received(:check)
      end
    end
  end

  RSpec.describe Truemail::Validator::Result do
    subject(:result_instance) { described_class.new }

    let(:email) { FFaker::Internet.email }

    specify do
      expect(result_instance.members).to include(*Truemail::Validator::RESULT_ATTRS)
    end

    it 'has .valid? alias' do
      expect((result_instance).respond_to?(:valid?)).to be(true)
      expect(result_instance.success).to eq(result_instance.valid?)
    end

    it 'has default values for attributes' do
      expect(result_instance.errors).to eq({})
      expect(result_instance.mail_servers).to eq([])
    end

    it 'accepts parametrized arguments' do
      expect(described_class.new(email: email).email).to eq(email)
    end
  end
end
