# frozen_string_literal: true

RSpec.describe Truemail::ConfigurationError do
  specify { expect(described_class).to be < StandardError }
end

RSpec.describe Truemail::ArgumentError do
  subject(:argument_error_instance) { described_class.new('arg_value', 'arg_name') }

  specify { expect(described_class).to be < StandardError }
  specify { expect(argument_error_instance).to be_an_instance_of(described_class) }
  specify { expect(argument_error_instance.to_s).to eq('arg_value is not a valid arg_name') }
end

RSpec.describe Truemail::PunycodeRepresenter do
  describe '.call' do
    subject(:service) { described_class.call(email) }

    context 'when email is not a string' do
      let(:email) { true }

      specify { expect(service).to be_nil }
    end

    context 'when email not includes ascii chars' do
      let(:email) { FFaker::Internet.email }

      it 'returns not changed email' do
        expect(SimpleIDN).not_to receive(:to_ascii)
        expect(service).to eq(email)
      end
    end

    context 'when email includes ascii chars' do
      let(:user) { 'niña' }
      let(:domain) { 'Mañana.cøm' }
      let(:punycode) { 'xn--maana-pta.xn--cm-lka' }
      let(:email) { "#{user}@#{domain}" }

      it 'returns email with domain represented as punycode' do
        expect(SimpleIDN).to receive(:to_ascii).with(domain.downcase).and_call_original
        expect(service).to eq("#{user}@#{punycode}")
      end
    end
  end
end

RSpec.describe Truemail::RegexConstant do
  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:REGEX_DOMAIN) }
    specify { expect(described_class).to be_const_defined(:REGEX_EMAIL_PATTERN) }
    specify { expect(described_class).to be_const_defined(:REGEX_DOMAIN_PATTERN) }
    specify { expect(described_class).to be_const_defined(:REGEX_DOMAIN_FROM_EMAIL) }
    specify { expect(described_class).to be_const_defined(:REGEX_SMTP_ERROR_BODY_PATTERN) }
  end

  describe 'Truemail::RegexConstant::REGEX_EMAIL_PATTERN' do
    subject(:regex_pattern) { described_class::REGEX_EMAIL_PATTERN }

    it 'allows from 6 to 255 chars' do
      expect(
        regex_pattern.match?(Truemail::GenerateEmailHelper.call(size: :min))
      ).to be(true)

      expect(
        regex_pattern.match?(Truemail::GenerateEmailHelper.call)
      ).to be(true)

      expect(
        regex_pattern.match?(Truemail::GenerateEmailHelper.call(size: :max))
      ).to be(true)
    end

    it 'not allows more then 255 chars' do
      expect(
        regex_pattern.match?(Truemail::GenerateEmailHelper.call(size: :out_of_range))
      ).to be(false)
    end

    it "allows '-', '_', '.', '+', numbers, letters case insensitive before @domain" do
      expect(regex_pattern.match?(Truemail::GenerateEmailHelper.call)).to be(true)
    end

    it 'allows tld size between 2 and 63 chars' do
      expect(regex_pattern.match?('i@i.io')).to be(true)
      expect(regex_pattern.match?("i@i.io#{'z' * 61}")).to be(true)
      expect(regex_pattern.match?("i@i.io#{'z' * 62}")).to be(false)
      expect(regex_pattern.match?('i@i.i')).to be(false)
    end

    it 'case insensitive' do
      %w[h@i.io H@i.io h@I.io h@i.Io H@i.Io Ho@iO.Io].each do |email|
        expect(regex_pattern.match?(email)).to be(true)
      end
    end

    it 'not allows special chars' do
      expect(
        regex_pattern.match?(Truemail::GenerateEmailHelper.call(invalid_email_with: %w[! ~ , ' & %]))
      ).to be(false)
    end

    it "not allows '-', '_', '.', '+' for one char username" do
      expect(
        regex_pattern.match?(Truemail::GenerateEmailHelper.call(size: :min, invalid_email_with: %w[- _ . +]))
      ).to be(false)
    end

    it 'allows not ascii chars in user and domain' do
      %w[niña@mañana.cØm квіточка@пошта.укр user@納豆.jp].each do |email_example|
        expect(regex_pattern.match?(email_example)).to be(true)
      end
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

    it 'allows tld size between 2 and 63 chars' do
      expect(regex_pattern.match?('domain.io')).to be(true)
      expect(regex_pattern.match?("domain.iq#{'z' * 61}")).to be(true)
      expect(regex_pattern.match?("domain.iq#{'z' * 62}")).to be(false)
      expect(regex_pattern.match?('domain')).to be(false)
    end

    it 'allows non ascii chars (internationalized domain names)' do
      expect(regex_pattern.match?('中国互联网络信息中心.中国')).to be(true)
    end

    it 'not allows dash as last char' do
      expect(regex_pattern.match?('1_.us')).to be(false)
      expect(regex_pattern.match?('1_.com_')).to be(false)
    end

    it 'not allows number in tld' do
      expect(regex_pattern.match?('domain.42')).to be(false)
    end

    it 'case insensitive' do
      %w[domain.io DOMAIN.IO Domain.io DoMain.Io].each do |domain|
        expect(regex_pattern.match?(domain)).to be(true)
      end
    end
  end

  describe 'Truemail::RegexConstant::REGEX_DOMAIN_FROM_EMAIL' do
    subject(:regex_pattern) { described_class::REGEX_DOMAIN_FROM_EMAIL }

    let(:email) { 'i@domain' }

    specify { expect(regex_pattern.match?(email)).to be(true) }
    specify { expect(email[regex_pattern, 1]).to eq('domain') }
  end

  describe 'Truemail::RegexConstant::REGEX_SMTP_ERROR_BODY_PATTERN' do
    subject(:regex_pattern) { described_class::REGEX_SMTP_ERROR_BODY_PATTERN }

    let(:smtp_error_context) { 'some smtp 550 error with' }

    %w[user account customer mailbox].map { |item| [item, item.upcase] }.flatten.each do |account_name_type|
      specify { expect(regex_pattern.match?("#{smtp_error_context} #{account_name_type}")).to be(true) }
    end
  end
end

RSpec.describe Truemail::Validate do
  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:Base) }
    specify { expect(described_class).to be_const_defined(:DomainListMatch) }
    specify { expect(described_class).to be_const_defined(:Regex) }
    specify { expect(described_class).to be_const_defined(:Mx) }
    specify { expect(described_class).to be_const_defined(:Smtp) }
  end
end
