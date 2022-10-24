# frozen_string_literal: true

module Truemail
  module Validate
    class ListMatch < Truemail::Validate::Base
      ERROR = 'blacklisted email'

      def run
        return success(true) if whitelisted? && !whitelist_validation?
        return unless whitelist_validation_case? || blacklisted?
        success(false)
        add_error(Truemail::Validate::ListMatch::ERROR)
      end

      private

      def email
        @email ||= result.email
      end

      def email_domain
        @email_domain ||=
          result.domain = email[Truemail::RegexConstant::REGEX_DOMAIN_FROM_EMAIL, 1]
      end

      def whitelisted?
        configuration.whitelisted_emails.include?(email) ||
          configuration.whitelisted_domains.include?(email_domain)
      end

      def whitelist_validation?
        configuration.whitelist_validation
      end

      def whitelist_validation_case?
        whitelist_validation? && !whitelisted?
      end

      def blacklisted?
        configuration.blacklisted_emails.include?(email) ||
          configuration.blacklisted_domains.include?(email_domain)
      end
    end
  end
end
