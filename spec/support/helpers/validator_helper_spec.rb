# frozen_string_literal: true

module Truemail
  RSpec.describe ValidatorHelper, type: :helper do
    describe '#create_servers_list' do
      subject(:servers_list) { create_servers_list }

      it 'returns an array with ips' do
        expect(servers_list).to be_an_instance_of(Array)
        expect(servers_list).not_to be_empty
      end
    end

    describe '#create_validator' do
      subject(:validator_instance) { create_validator(validation_type, email, mx_servers, success: success_status) }

      let(:email) { FFaker::Internet.email }
      let(:mx_servers) { create_servers_list }

      describe 'successful validator instance' do
        let(:validator_instance_result) { validator_instance.result }
        let(:validator_instance_result_configuration) { validator_instance_result.configuration }
        let(:success_status) { true }

        shared_examples 'successful validator instance' do
          it 'creates successful validator instance' do
            expect(validator_instance_result.success).to be(success_status)
            expect(validator_instance_result.email).to eq(email)
            expect(validator_instance_result.errors).to be_empty
            expect(validator_instance_result.smtp_debug).to be_nil
            expect(validator_instance_result_configuration).to be_an_instance_of(Truemail::Configuration)
            expect(validator_instance.validation_type).to eq(validation_type)
          end
        end

        context 'with whitelist validation type' do
          let(:validation_type) { :whitelist }

          include_examples 'successful validator instance'

          it 'has necessary validator instance result attributes' do
            expect(validator_instance_result.domain).to be_nil
            expect(validator_instance_result.mail_servers).to be_empty
            expect(validator_instance_result_configuration.whitelisted_domains).not_to be_empty
          end
        end

        context 'with regex validation type' do
          let(:validation_type) { :regex }

          include_examples 'successful validator instance'

          it 'has necessary validator instance result attributes' do
            expect(validator_instance_result.domain).to be_nil
            expect(validator_instance_result.mail_servers).to be_empty
          end
        end

        context 'with mx validation type' do
          let(:validation_type) { :mx }

          include_examples 'successful validator instance'

          it 'has necessary validator instance result attributes' do
            expect(validator_instance_result.domain).not_to be_nil
            expect(validator_instance_result.mail_servers).to eq(mx_servers)
          end
        end

        context 'with smtp validation type' do
          let(:validation_type) { :smtp }

          include_examples 'successful validator instance'

          it 'has necessary validator instance result attributes' do
            expect(validator_instance_result.domain).not_to be_nil
            expect(validator_instance_result.mail_servers).to eq(mx_servers)
          end
        end

        context 'without params' do
          subject(:validator_instance) { create_validator }

          it 'creates successful smtp validator instance' do
            expect(validator_instance.result.success).to be(true)
            expect(validator_instance_result.domain).not_to be_nil
            expect(validator_instance_result.mail_servers).not_to be_empty
            expect(validator_instance_result.mail_servers).not_to eq(mx_servers)
            expect(validator_instance.validation_type).to eq(:smtp)
          end
        end
      end

      describe 'fail validator instance' do
        let(:validator_instance_result) { validator_instance.result }
        let(:validator_instance_result_configuration) { validator_instance_result.configuration }
        let(:success_status) { false }

        shared_examples 'fail validator instance' do
          it 'creates fail validator instance' do
            expect(validator_instance_result.success).to be(success_status)
            expect(validator_instance_result.email).not_to be_nil
            expect(validator_instance_result.errors).not_to be_empty
            expect(validator_instance_result_configuration).to be_an_instance_of(Truemail::Configuration)
          end
        end

        context 'with whitelist validation type' do
          let(:validation_type) { :whitelist }

          include_examples 'fail validator instance'

          it 'has necessary validator instance result attributes' do
            expect(validator_instance_result.domain).to be_nil
            expect(validator_instance_result.errors).to include(:domain_list_match)
            expect(validator_instance_result.mail_servers).to be_empty
            expect(validator_instance_result.smtp_debug).to be_nil
            expect(validator_instance_result_configuration.blacklisted_domains).not_to be_empty
            expect(validator_instance.validation_type).to eq(:blacklist)
          end
        end

        context 'with regex validation type' do
          let(:validation_type) { :regex }

          include_examples 'fail validator instance'

          it 'has necessary validator instance result attributes' do
            expect(validator_instance_result.domain).to be_nil
            expect(validator_instance_result.errors).to include(validation_type)
            expect(validator_instance_result.mail_servers).to be_empty
            expect(validator_instance.validation_type).to eq(validation_type)
          end
        end

        context 'with mx validation type' do
          let(:validation_type) { :mx }

          include_examples 'fail validator instance'

          it 'has necessary validator instance result attributes' do
            expect(validator_instance_result.domain).not_to be_nil
            expect(validator_instance_result.errors).to include(validation_type)
            expect(validator_instance_result.mail_servers).to be_empty
            expect(validator_instance.validation_type).to eq(validation_type)
          end
        end

        context 'with smtp validation type' do
          let(:validation_type) { :smtp }

          include_examples 'fail validator instance'

          it 'has necessary validator instance result attributes' do
            expect(validator_instance_result.domain).not_to be_nil
            expect(validator_instance_result.errors).to include(validation_type)
            expect(validator_instance_result.mail_servers).to eq(mx_servers)
            expect(validator_instance_result.smtp_debug).not_to be_empty
            expect(validator_instance_result.smtp_debug.first.response.errors).to include(rcptto: 'user not found')
            expect(validator_instance.validation_type).to eq(validation_type)
          end
        end
      end
    end
  end
end
