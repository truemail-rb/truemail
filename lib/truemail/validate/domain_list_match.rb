# frozen_string_literal: true

module Truemail
  module Validate
    class DomainListMatch < Truemail::Worker
      ERROR = 'blacklisted email'

      def run
        return if success(domain_in_white_list?)
        return unless success(domain_in_black_list?)
        add_error(Truemail::Validate::DomainListMatch::ERROR)
      end

      private

      def email_domain
        @email_domain ||= result.email[Truemail::RegexConstant::REGEX_DOMAIN_FROM_EMAIL, 1]
      end

      def domain_in_white_list?
        configuration.whitelisted_domains.include?(email_domain)
      end

      def domain_in_black_list?
        configuration.blacklisted_domains.include?(email_domain)
      end
    end
  end
end
