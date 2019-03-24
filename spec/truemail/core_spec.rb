# frozen_string_literal: true

module Truemail
  RSpec.describe Truemail::ArgumentError do
    subject(:argument_error_instance) { described_class.new('parameter', Array) }

    specify { expect(argument_error_instance).to be_an_instance_of(described_class) }
    specify { expect(argument_error_instance.to_s).to eq('parameter is not a valid Array') }
  end

  RSpec.describe Truemail::RegexConstant do
    describe 'defined constants' do
      specify { expect(described_class).to be_const_defined(:REGEX_DOMAIN) }
      specify { expect(described_class).to be_const_defined(:REGEX_EMAIL_PATTERN) }
      specify { expect(described_class).to be_const_defined(:REGEX_DOMAIN_PATTERN) }
    end

    describe 'Truemail::RegexConstant::REGEX_EMAIL_PATTERN' do
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

    describe 'Truemail::RegexConstant::REGEX_DOMAIN_PATTERN' do
      subject(:regex_pattern) { described_class::REGEX_DOMAIN_PATTERN }

      it 'allows from 4 to 255 chars' do
        expect(regex_pattern.match?('i.us')).to be(true)
        expect(regex_pattern.match?("#{'i' * 252}.us")).to be(true)
      end

      it 'allows numbers, letters, dashs' do
        expect(regex_pattern.match?('1.us')).to be(true)
        expect(regex_pattern.match?('l.us')).to be(true)
        expect(regex_pattern.match?('1domain.us')).to be(true)
        expect(regex_pattern.match?('1-domain.us')).to be(true)
      end

      it 'allows nested subdomains' do
        expect(regex_pattern.match?('42.com')).to be(true)
        expect(regex_pattern.match?('42.subdomain.domain')).to be(true)
        expect(regex_pattern.match?('service.subdomain.company.domain')).to be(true)
      end

      it 'allows tld size between 2 and 7 chars' do
        expect(regex_pattern.match?('domain.io')).to be(true)
        expect(regex_pattern.match?('domain.rentals')).to be(true)
      end

      it 'not allows dash as last char' do
        expect(regex_pattern.match?('1_.us')).to be(false)
        expect(regex_pattern.match?('1_.com_')).to be(false)
      end

      it 'not allows number in tld' do
        expect(regex_pattern.match?('domain.42')).to be(false)
      end
    end
  end

  RSpec.describe Truemail::Validate do
    describe 'defined constants' do
      specify { expect(described_class).to be_const_defined(:Base) }
      specify { expect(described_class).to be_const_defined(:Regex) }
      specify { expect(described_class).to be_const_defined(:Mx) }
      specify { expect(described_class).to be_const_defined(:Smtp) }
    end
  end
end
