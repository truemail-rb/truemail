# frozen_string_literal: true

module Truemail
  module ContextHelper
    NON_ASCII_WORDS = %w[mañana ĉapelo dấu παράδειγμα 屋企].freeze

    def random_email
      faker.email
    end

    def random_internationalized_email
      "#{faker.username}@#{Truemail::ContextHelper::NON_ASCII_WORDS.sample}.#{faker.domain_suffix}"
    end

    def random_ip_address
      faker.ip_v4_address
    end

    def random_domain_name
      faker.domain_name
    end

    def random_uniq_domain_name
      faker.unique.domain_name
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

    private

    def faker
      Faker::Internet
    end
  end
end
