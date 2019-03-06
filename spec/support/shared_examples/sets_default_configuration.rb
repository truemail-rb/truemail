module Truemail
  RSpec.shared_examples 'sets default configuration' do
    it 'sets default configuration settings' do
      expect(subject.email_pattern).to be_an_instance_of(Regexp)
      expect(subject.verifier_email).to be_nil
      expect(subject.verifier_domain).to be_nil
    end
  end
end
