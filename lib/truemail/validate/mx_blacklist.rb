# frozen_string_literal: true

module Truemail
  module Validate
    class MxBlacklist < Truemail::Validate::Base
      ERROR = 'blacklisted mx server ip address'

      def run
        return false unless Truemail::Validate::Mx.check(result)
        return true if success(mail_servers.none?(&blacklisted_ip?))
        add_error(Truemail::Validate::MxBlacklist::ERROR)
        false
      end

      private

      def blacklisted_ip?
        ->(mail_server) { configuration.blacklisted_mx_ip_addresses.include?(mail_server) }
      end
    end
  end
end
