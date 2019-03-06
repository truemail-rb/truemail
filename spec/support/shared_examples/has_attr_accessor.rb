module Truemail
  RSpec.shared_examples 'has attr_accessor' do
    %i[email_pattern verifier_email verifier_domain].each do |attribute|
      it "has attr_accessor :#{attribute}" do
        expect(subject.respond_to?(attribute)).to be(true)
        expect(subject.respond_to?(:"#{attribute}=")).to be(true)
      end
    end
  end
end
