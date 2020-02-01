# frozen_string_literal: true

RSpec.describe Truemail::Validator do
  subject(:validator_instance) { described_class.new(email, options) }

  let(:email) { FFaker::Internet.email }
  let(:configuration_instance) { create_configuration }
  let(:configuration) { { configuration: configuration_instance } }
  let(:options) { { **configuration } }
  let(:validator_instance_result) { validator_instance.result }

  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:RESULT_ATTRS) }
    specify { expect(described_class).to be_const_defined(:VALIDATION_TYPES) }
    specify { expect(described_class).to be_const_defined(:Result) }
  end

  describe '.new' do
    Truemail::Validator::VALIDATION_TYPES.each do |validation_type|
      context "with: #{validation_type}" do
        let(:options) { { with: validation_type, **configuration } }

        it "creates validator instance with #{validation_type} validation type" do
          expect(validator_instance.validation_type).to eq(validation_type)
        end

        it 'creates default validator result' do
          expect(validator_instance_result).to be_an_instance_of(Truemail::Validator::Result)
          expect(validator_instance_result.configuration).to eq(configuration_instance)
          expect(validator_instance_result.success).to be_nil
          expect(validator_instance_result.email).to eq(email)
          expect(validator_instance_result.domain).to be_nil
          expect(validator_instance_result.mail_servers).to eq([])
          expect(validator_instance_result.errors).to eq({})
        end
      end
    end

    context 'with invalid validation type' do
      let(:options) { { with: :invalid_validation_type, **configuration } }

      specify do
        expect { validator_instance }
          .to raise_error(Truemail::ArgumentError, "#{options[:with]} is not a valid argument")
      end
    end
  end

  describe '#run' do
    subject(:validator_instance_run) { validator_instance.run }

    let(:validator_instance) { described_class.new(email, with: validation_type, **configuration) }
    let(:validation_type) { :regex }

    before { allow(Truemail::Validate::DomainListMatch).to receive(:check) }

    describe 'validation detection layer' do
      before { allow(validator_instance).to receive(:result_not_changed?).and_return(condition) }

      context 'when email not in whitelist/blacklist' do
        let(:condition) { true }

        it 'calls predefined validation class' do
          expect(Truemail::Validate::Regex).to receive(:check)
          expect(validator_instance_run).to be_an_instance_of(described_class)
        end

        specify do
          expect { validator_instance_run }.not_to change(validator_instance, :validation_type)
        end
      end

      context 'when email in the whitelist/blacklist' do
        let(:condition) { false }

        it 'not calls predefined validation class' do
          expect(Truemail::Validate::Regex).not_to receive(:check)
          expect(validator_instance_run).to be_an_instance_of(described_class)
        end

        context 'with whitelisted email' do
          specify do
            allow(validator_instance_result).to receive(:success).and_return(true)
            expect { validator_instance_run }.to change(validator_instance, :validation_type).from(validation_type).to(:whitelist)
          end
        end

        context 'with blacklisted email' do
          specify do
            allow(validator_instance_result).to receive(:success).and_return(false)
            expect { validator_instance_run }.to change(validator_instance, :validation_type).from(validation_type).to(:blacklist)
          end
        end
      end
    end

    describe 'logger event trigger' do
      before { allow(validator_instance).to receive(:logger).and_return(logger_instance) }

      describe 'works without logs' do
        context 'when logger not configured' do
          let(:logger_instance) { nil }

          it 'not pushes logs' do
            expect(logger_instance).not_to receive(:push)
            expect(validator_instance_run).to be_an_instance_of(described_class)
          end
        end
      end

      describe 'works with logs' do
        context 'when logger configured' do
          let(:logger_instance) { true }

          it 'pushes logs' do
            expect(logger_instance).to receive(:push).with(validator_instance)
            expect(validator_instance_run).to be_an_instance_of(described_class)
          end
        end
      end
    end
  end

  describe '#as_json' do
    subject(:validator_instance_as_json) { validator_instance.as_json }

    specify do
      expect(Truemail::Log::Serializer::Json).to receive(:call).with(validator_instance).and_call_original
      expect(validator_instance_as_json).to match_json_schema('validator')
    end
  end

  describe '#select_validation_type' do
    subject(:select_validation_type) do
      described_class.new(email, with: current_validation_type, **configuration).validation_type
    end

    let(:current_validation_type) { :regex }
    let(:new_validation_type)     { :mx }
    let(:domain)                  { FFaker::Internet.domain_name }

    before { configuration_instance.validation_type_for = { domain => new_validation_type } }

    context 'when domain of current email exists in configuration' do
      let(:email) { "email@#{domain}" }

      it 'returns predefined domain validation type' do
        expect(select_validation_type).to eq(new_validation_type)
      end
    end

    context 'when domain of current email not exists in configuration' do
      let(:email) { 'email@other-great.domain' }

      it 'uses current validation type' do
        expect(select_validation_type).to eq(current_validation_type)
      end
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
    expect(result_instance.respond_to?(:valid?)).to be(true)
    expect(result_instance.success).to eq(result_instance.valid?)
  end

  it 'has default values for attributes' do
    expect(result_instance.errors).to eq({})
    expect(result_instance.mail_servers).to eq([])
  end

  it 'accepts parametrized arguments' do
    expect(described_class.new(email: email).email).to eq(email)
  end

  describe '#punycode_email' do
    subject(:result_instance) { described_class.new(email: email) }

    it 'calls with memoization punycode representer' do
      expect(Truemail::PunycodeRepresenter).to receive(:call).once.with(email).and_call_original
      2.times { result_instance.punycode_email }
    end
  end
end
