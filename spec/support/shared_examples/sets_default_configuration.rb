module Truemail
  RSpec.shared_examples 'sets default configuration' do
    it 'sets default configuration settings' do
      expect(configuration_instance.email_pattern).to be_an_instance_of(Regexp)
      expect(configuration_instance.verifier_email).to be_nil
      expect(configuration_instance.verifier_domain).to be_nil
    end
  end
end
