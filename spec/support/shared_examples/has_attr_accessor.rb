RSpec.shared_examples 'has attr_accessor' do
  %i[email_pattern verifier_email verifier_domain].each do |attribute|
    it "has attr_accessor :#{attribute}" do
      expect(configuration_instance.respond_to?(attribute)).to be(true)
      expect(configuration_instance.respond_to?(:"#{attribute}=")).to be(true)
    end
  end
end
