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

RSpec.describe Truemail::RegexConstant do
  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:REGEX_DOMAIN) }
    specify { expect(described_class).to be_const_defined(:REGEX_EMAIL_PATTERN) }
    specify { expect(described_class).to be_const_defined(:REGEX_DOMAIN_PATTERN) }
    specify { expect(described_class).to be_const_defined(:REGEX_DOMAIN_FROM_EMAIL) }
    specify { expect(described_class).to be_const_defined(:REGEX_SMTP_ERROR_BODY_PATTERN) }
    specify { expect(described_class).to be_const_defined(:REGEX_IP_ADDRESS) }
    specify { expect(described_class).to be_const_defined(:REGEX_IP_ADDRESS_PATTERN) }
    specify { expect(described_class).to be_const_defined(:REGEX_PORT_NUMBER) }
    specify { expect(described_class).to be_const_defined(:REGEX_DNS_SERVER_ADDRESS_PATTERN) }
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

    %w[user account customer mailbox].flat_map { |item| [item, item.upcase] }.each do |account_name_type|
      specify { expect(regex_pattern.match?("#{smtp_error_context} #{account_name_type}")).to be(true) }
    end
  end

  describe 'Truemail::RegexConstant::REGEX_IP_ADDRESS_PATTERN' do
    subject(:regex_pattern) { described_class::REGEX_IP_ADDRESS_PATTERN }

    describe 'Success' do
      specify { expect(regex_pattern.match?(random_ip_address)).to be(true) }
    end

    describe 'Failure' do
      %w[10.300.0.256 11.287.0.1 172.1600.0.0 -0.1.1.1 8.08.8.8 192.168.0.255a 0.00.0.42].each do |invalid_ip_address|
        specify { expect(regex_pattern.match?(invalid_ip_address)).to be(false) }
      end
    end
  end

  describe 'Truemail::RegexConstant::REGEX_DNS_SERVER_ADDRESS_PATTERN' do
    subject(:regex_pattern) { described_class::REGEX_DNS_SERVER_ADDRESS_PATTERN }

    def valid_port_number
      ->(item) { "#{item}:#{rand(1..65_535)}" }
    end

    def invalid_port_number
      outside = 65_536
      outside_port_number = ((outside..(outside + rand)).to_a << 0).sample
      ->(item) { "#{item}:#{outside_port_number}" }
    end

    shared_examples 'match with regex dns server address pattern' do
      specify { ip_range.all? { |item| expect(regex_pattern.match?(item)).to be(expectation) } }
    end

    shared_examples 'match with regex port number pattern' do
      specify { expect(regex_pattern.match?("#{valid_local_ip_addresses.first}:#{port_number}")).to be(expectation) }
    end

    let(:valid_local_ip_addresses) { %w[127.0.0.1 10.0.0.1 169.254.0.0 172.16.0.0 192.168.0.1 0.0.0.0] }
    let(:valid_internet_ip_addresses) { create_servers_list }

    describe 'Success' do
      let(:local_ip_addresses) { valid_local_ip_addresses }
      let(:internet_ip_addresses) { valid_internet_ip_addresses }
      let(:expectation) { true }

      context 'when valid ip address without port number' do
        let(:ip_range) { local_ip_addresses + internet_ip_addresses }

        include_examples 'match with regex dns server address pattern'
      end

      context 'when valid ip address with valid port number' do
        let(:ip_range) { (local_ip_addresses + internet_ip_addresses).map(&valid_port_number) }

        include_examples 'match with regex dns server address pattern'
      end

      describe 'integration REGEX_PORT_NUMBER into REGEX_DNS_SERVER_ADDRESS_PATTERN' do
        context 'when port number in range from 1 to 9' do
          let(:port_number) { rand(1..9) }

          include_examples 'match with regex port number pattern'
        end

        context 'when port number in range from 10 to 99' do
          let(:port_number) { rand(10..90) }

          include_examples 'match with regex port number pattern'
        end

        context 'when port number in range from 100 to 999' do
          let(:port_number) { rand(100..999) }

          include_examples 'match with regex port number pattern'
        end

        context 'when port number in range from 1000 to 9999' do
          let(:port_number) { rand(1_000..9_999) }

          include_examples 'match with regex port number pattern'
        end

        context 'when port number in range from 10000 to 65000' do
          let(:port_number) { rand(10_000..65_000) }

          include_examples 'match with regex port number pattern'
        end

        context 'when port number in range from 65000 to 65499' do
          let(:port_number) { rand(65_000..65_499) }

          include_examples 'match with regex port number pattern'
        end

        context 'when port number in range from 65500 to 65535' do
          let(:port_number) { rand(65_500..65_535) }

          include_examples 'match with regex port number pattern'
        end
      end
    end

    describe 'Failure' do
      let(:local_ip_addresses) { %w[10.0.0.256 169.300.0.0 172.16.257.0 192.168.0.260 0.0.0.00] }
      let(:internet_ip_addresses) { %w[01.1.1.1 8.08.8.8 231.266.255.1000] }
      let(:expectation) { false }

      context 'when invalid ip address without port number' do
        let(:ip_range) { local_ip_addresses + internet_ip_addresses }

        include_examples 'match with regex dns server address pattern'
      end

      context 'when valid ip address with invalid port number' do
        let(:ip_range) { (valid_local_ip_addresses + valid_internet_ip_addresses).map(&invalid_port_number) }

        include_examples 'match with regex dns server address pattern'
      end

      context 'when invalid ip address with valid port number' do
        let(:ip_range) { (local_ip_addresses + internet_ip_addresses).map(&valid_port_number) }

        include_examples 'match with regex dns server address pattern'
      end

      context 'when invalid ip address with invalid port number' do
        let(:ip_range) { (local_ip_addresses + internet_ip_addresses).map(&invalid_port_number) }

        include_examples 'match with regex dns server address pattern'
      end

      context 'with zero port number' do
        let(:ip_range) { %w[0.0.0.0:0 255.255.255.255:0] }

        include_examples 'match with regex dns server address pattern'
      end

      describe 'integration REGEX_PORT_NUMBER into REGEX_DNS_SERVER_ADDRESS_PATTERN' do
        context 'when port number is equal to 0' do
          let(:port_number) { 0 }

          include_examples 'match with regex port number pattern'
        end

        context 'when port number is outside of range 1-65353' do
          let(:port_number) { rand(65_536..70_000) }

          include_examples 'match with regex port number pattern'
        end
      end
    end
  end
end

RSpec.describe Truemail::Validate do
  describe 'defined constants' do
    specify { expect(described_class).to be_const_defined(:Base) }
    specify { expect(described_class).to be_const_defined(:DomainListMatch) }
    specify { expect(described_class).to be_const_defined(:Regex) }
    specify { expect(described_class).to be_const_defined(:Mx) }
    specify { expect(described_class).to be_const_defined(:MxBlacklist) }
    specify { expect(described_class).to be_const_defined(:Smtp) }
  end
end
