# frozen_string_literal: true

module Truemail
  module Validate
    class Smtp < Truemail::Validate::Base
      ERROR = 'smtp error'

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
        return true if success(not_includes_user_not_found_errors?)
        add_error(Truemail::Validate::Smtp::ERROR)
        false
      end

      private

      def fail_fast?
        configuration.smtp_fail_fast
      end

      def filtered_mail_servers_by_fail_fast_scenario
        fail_fast? ? mail_servers.first(1) : mail_servers
      end

      def attempts
        @attempts ||= begin
          return {} if fail_fast? || !mail_servers.one?
          { attempts: configuration.connection_attempts }
        end
      end

      def request
        smtp_results.last
      end

      def rcptto_error
        request.response.errors[:rcptto]
      end

      def establish_smtp_connection
        filtered_mail_servers_by_fail_fast_scenario.each do |mail_server|
          smtp_results << Truemail::Validate::Smtp::Request.new(
            configuration: configuration, host: mail_server, email: result.punycode_email, **attempts
          )
          next unless request.check_port
          request.run || rcptto_error ? break : next
        end
      end

      def success_response?
        smtp_results.map(&:response).any?(&:rcptto)
      end

      def not_includes_user_not_found_errors?
        return unless configuration.smtp_safe_check
        result.smtp_debug.map(&:response).map(&:errors).all? do |errors|
          next true unless errors.key?(:rcptto)
          errors.slice(:rcptto).values.none? do |error|
            configuration.smtp_error_body_pattern.match?(error)
          end
        end
      end
    end
  end
end
