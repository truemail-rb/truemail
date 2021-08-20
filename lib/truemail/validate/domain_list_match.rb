# frozen_string_literal: true

module Truemail
  module Validate
    class DomainListMatch < Truemail::Validate::Base
      ERROR = 'blacklisted email'

      def run
        return success(true) if whitelisted_domain? && !whitelist_validation?
        return unless whitelist_validation_case? || blacklisted_domain?
        success(false)
        add_error(Truemail::Validate::DomainListMatch::ERROR)
      end

      private

      def email_domain
        @email_domain ||=
          result.domain = result.email[Truemail::RegexConstant::REGEX_DOMAIN_FROM_EMAIL, 1]
      end

      def whitelisted_domain?
        configuration.whitelisted_domains.include?(email_domain)
      end

      def whitelist_validation?
        configuration.whitelist_validation
      end

      def whitelist_validation_case?
        whitelist_validation? && !whitelisted_domain?
      end

      def blacklisted_domain?
        configuration.blacklisted_domains.include?(email_domain)
      end
    end
  end
end
