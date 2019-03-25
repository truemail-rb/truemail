# frozen_string_literal: true

module Truemail
  module Validate
    class Smtp < Truemail::Validate::Base
      ERROR = 'smtp error'
      ERROR_BODY = /(?=.*550)(?=.*(user|account)).*/i.freeze

      attr_reader :smtp_results

      def initialize(result)
        super(result)
        @smtp_results = []
      end

      def run
        return false unless Truemail::Validate::Mx.check(result)
        establish_smtp_connection
        return true if success(success_response?)
        result.smtp_debug = smtp_results
        return true if not_include_user_not_found_errors
        add_error(Truemail::Validate::Smtp::ERROR)
        false
      end

      private

      def request
        smtp_results.last
      end

      def rcptto_error
        request.response.errors[:rcptto]
      end

      def establish_smtp_connection
        result.mail_servers.each do |mail_server|
          smtp_results << Truemail::Validate::Smtp::Request.new(host: mail_server, email: result.email)
          next unless request.check_port
          request.run || rcptto_error ? break : next
        end
      end

      def success_response?
        smtp_results.map(&:response).any?(&:rcptto)
      end

      def not_include_user_not_found_errors
        return unless Truemail.configuration.smtp_safe_check
        result.smtp_debug.map(&:response).map(&:errors).all? do |errors|
          errors.slice(:rcptto).values.map { |error| Truemail::Validate::Smtp::ERROR_BODY.match?(error) }.none?
        end
      end
    end
  end
end
