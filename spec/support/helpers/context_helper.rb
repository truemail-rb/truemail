# frozen_string_literal: true

module Truemail
  module ContextHelper
    NON_ASCII_WORDS = %w[mañana ĉapelo dấu παράδειγμα 屋企].freeze

    def random_email
      ffaker.email
    end

    def random_uniq_email
      ffaker.unique.email
    end

    def random_internationalized_email
      "#{ffaker.user_name}@#{Truemail::ContextHelper::NON_ASCII_WORDS.sample}.#{ffaker.domain_suffix}"
    end

    def random_ip_address
      ffaker.ip_v4_address
    end

    def random_domain_name
      ffaker.domain_name
    end

    def random_uniq_domain_name
      ffaker.unique.domain_name
    end

    def rdns_lookup_host_address(host_address)
      DnsMock::Representer::RdnsLookup.call(host_address)
    end

    def domain_from_email(email)
      email[Truemail::RegexConstant::REGEX_DOMAIN_FROM_EMAIL, 1]
    end

    def email_punycode_domain(email)
      DnsMock::Representer::Punycode.call(domain_from_email(email))
    end

    def attempts_getter
      ->(smtp_request_instance) { smtp_request_instance.send(:attempts) }
    end

    private

    def ffaker
      FFaker::Internet
    end
  end
end
