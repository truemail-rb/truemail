module Truemail
  module Validate
    class Smtp
      SMTP_PORT = 25
      CONNECTION_TIMEOUT_ERROR = 'connection timed out'.freeze
      RESPONSE_TIMEOUT_ERROR = 'server response timeout'.freeze
      CONNECTION_DROPPED = 'server dropped connection after response'.freeze

      Request = Struct.new(:host, :email, :response, keyword_init: true) do
        require 'net/smtp'

        def initialize(response: Truemail::Validate::Smtp::Response.new, **args)
          super
        end

        def check_port
          Timeout.timeout(configuration.connection_timeout) do
            return response.port_opened =
              !TCPSocket.new(host, Truemail::Validate::Smtp::SMTP_PORT).close
          end
        rescue Timeout::Error
          response.port_opened = false
        end

        def run
          session.start do |smtp_request|
            response.connection = true
            smtp_handshakes(smtp_request, response)
          end
        rescue => error
          assign_error(attribute: :connection, message: compose_from(error))
        end

        private

        def configuration
          Truemail.configuration.dup.freeze
        end

        def session
          Net::SMTP.new(host, Truemail::Validate::Smtp::SMTP_PORT).tap do |settings|
            settings.open_timeout = configuration.connection_timeout
            settings.read_timeout = configuration.response_timeout
          end
        end

        def compose_from(error)
          case error.class.name
          when 'Net::OpenTimeout' then Truemail::Validate::Smtp::CONNECTION_TIMEOUT_ERROR
          when 'Net::ReadTimeout' then Truemail::Validate::Smtp::RESPONSE_TIMEOUT_ERROR
          when 'EOFError' then Truemail::Validate::Smtp::CONNECTION_DROPPED
          else error.message
          end
        end

        def assign_error(attribute:, message:)
          response.errors[attribute] = message
          response.public_send(:"#{attribute}=", false)
        end

        def session_data
          {
            helo: configuration.verifier_domain,
            mailfrom: configuration.verifier_email,
            rcptto: email
          }
        end

        def smtp_resolver(smtp_request, method, value)
          smtp_request.public_send(method, value)
        rescue => error
          assign_error(attribute: method, message: compose_from(error))
        end

        def smtp_handshakes(smtp_request, smtp_response)
          !!session_data.each do |method, value|
            break unless smtp_response.public_send(:"#{method}=", smtp_resolver(smtp_request, method, value))
          end
        end
      end
    end
  end
end