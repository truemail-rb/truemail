# frozen_string_literal: true

module Truemail
  module Validate
    class Smtp
      class Request
        SMTP_PORT = 25
        CONNECTION_TIMEOUT_ERROR = 'connection timed out'
        RESPONSE_TIMEOUT_ERROR = 'server response timeout'
        CONNECTION_DROPPED = 'server dropped connection after response'

        attr_reader :configuration, :host, :email, :response

        def initialize(configuration:, host:, email:, attempts: nil, port_open_status: proc { true })
          @configuration = Truemail::Validate::Smtp::Request::Configuration.new(configuration)
          @response = Truemail::Validate::Smtp::Response.new
          @host = host
          @email = email
          @attempts = attempts
          @port_open_status = port_open_status
        end

        def check_port
          response.port_opened = ::Socket.tcp(
            host,
            Truemail::Validate::Smtp::Request::SMTP_PORT,
            connect_timeout: configuration.connection_timeout,
            &port_open_status
          )
        rescue => error
          retry if attempts_exist? && error.is_a?(::Errno::ETIMEDOUT)
          response.port_opened = false
        end

        def run
          session.start(verifier_domain, &session_actions)
        rescue => error
          retry if attempts_exist?
          assign_error(attribute: :connection, message: compose_from(error))
        end

        private

        class Configuration
          REQUEST_PARAMS = %i[connection_timeout response_timeout verifier_domain verifier_email].freeze

          def initialize(configuration)
            Truemail::Validate::Smtp::Request::Configuration::REQUEST_PARAMS.each do |attribute|
              self.class.class_eval { attr_reader attribute }
              instance_variable_set(:"@#{attribute}", configuration.public_send(attribute))
            end
          end
        end

        class Session
          require 'net/smtp'

          def initialize(host, port, connection_timeout, response_timeout)
            @net_smtp = (old_net_smtp? ? ::Net::SMTP.new(host, port) : ::Net::SMTP.new(host, port, tls_verify: false)).tap do |settings|
              settings.open_timeout = connection_timeout
              settings.read_timeout = response_timeout
            end
          end

          def start(helo_domain, &block)
            return net_smtp.start(helo_domain, &block) if old_net_smtp?
            net_smtp.start(helo: helo_domain, &block)
          end

          private

          attr_reader :net_smtp

          def old_net_smtp?
            !::Net::SMTP.const_defined?(:VERSION) || ::Net::SMTP::VERSION < '0.3.0'
          end
        end

        attr_reader :attempts, :port_open_status

        def attempts_exist?
          return false unless attempts
          (@attempts -= 1).positive?
        end

        def session
          Truemail::Validate::Smtp::Request::Session.new(
            host,
            Truemail::Validate::Smtp::Request::SMTP_PORT,
            configuration.connection_timeout,
            configuration.response_timeout
          )
        end

        def compose_from(error)
          case error.class.name
          when 'Net::OpenTimeout' then Truemail::Validate::Smtp::Request::CONNECTION_TIMEOUT_ERROR
          when 'Net::ReadTimeout' then Truemail::Validate::Smtp::Request::RESPONSE_TIMEOUT_ERROR
          when 'EOFError' then Truemail::Validate::Smtp::Request::CONNECTION_DROPPED
          else error.message
          end
        end

        def assign_error(attribute:, message:)
          response.errors[attribute] = message
          response.public_send(:"#{attribute}=", false)
        end

        def session_data
          { mailfrom: configuration.verifier_email, rcptto: email }
        end

        def smtp_resolver(smtp_request, method, value)
          smtp_request.public_send(method, value)
        rescue => error
          assign_error(attribute: method, message: compose_from(error))
        end

        def verifier_domain
          configuration.verifier_domain
        end

        def session_actions
          lambda { |smtp_request|
            response.connection = response.helo = true
            smtp_handshakes(smtp_request, response)
          }
        end

        def smtp_handshakes(smtp_request, smtp_response)
          session_data.all? do |method, value|
            smtp_response.public_send(:"#{method}=", smtp_resolver(smtp_request, method, value))
          end
        end
      end
    end
  end
end
