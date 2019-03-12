module Truemail
  module Validate
    class Mx < Truemail::Validate::Base
      require 'resolv'

      ERROR = 'mx records not found'.freeze

      def run
        return false unless Truemail::Validate::Regex.check(result)
        result.domain = result.email[Truemail::RegexConstant::REGEX_EMAIL_PATTERN, 3]
        return true if success(!result.mail_servers.push(*mx_records(result.domain)).empty?)
        add_error(Truemail::Validate::Mx::ERROR)
        false
      end

      private

      def mx_records(domain)
        mx_records = Resolv::DNS.open { |dns| dns.getresources(domain, Resolv::DNS::Resource::IN::MX) }
        mx_records.sort_by(&:preference).map { |mx_record| mx_record.exchange.to_s }
      end
    end
  end
end
