module Truemail
  RSpec.describe RegexConstant do
    describe 'REGEX_EMAIL_PATTERN' do
      subject(:regex_pattern) { described_class::REGEX_EMAIL_PATTERN }

      it 'allows from 6 to 255 chars' do
        expect(
          regex_pattern.match?(GenerateEmailHelper.call(size: :min))
        ).to be(true)

        expect(
          regex_pattern.match?(GenerateEmailHelper.call)
        ).to be(true)

        expect(
          regex_pattern.match?(GenerateEmailHelper.call(size: :max))
        ).to be(true)
      end

      it 'not allows more then 255 chars' do
        expect(
          regex_pattern.match?(GenerateEmailHelper.call(size: :out_of_range))
        ).to be(false)
      end

      it "allows '-', '_', '.', numbers, letters case insensitive before @domain" do
        expect(regex_pattern.match?(GenerateEmailHelper.call)).to be(true)
      end

      it 'not allows special chars' do
        expect(
          regex_pattern.match?(GenerateEmailHelper.call(invalid_email_with: %w[! ~ , ' & %]))
        ).to be(false)
      end
    end
  end
end
