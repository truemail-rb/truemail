# frozen_string_literal: true

module Truemail
  RSpec.shared_examples 'has attr_accessor' do
    %i[
      email_pattern
      verifier_email
      verifier_domain
      connection_timeout
      response_timeout
      retry_count
      smtp_safe_check
    ].each do |attribute|
      it "has attr_accessor :#{attribute}" do
        expect(configuration_instance.respond_to?(attribute)).to be(true)
        expect(configuration_instance.respond_to?(:"#{attribute}=")).to be(true)
      end
    end
  end
end
