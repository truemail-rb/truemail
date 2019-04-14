# frozen_string_literal: true

module Truemail
  module Validate
    class Base < Truemail::Worker
      private

      def add_error(message)
        result.errors[self.class.name.split('::').last.downcase.to_sym] = message
      end

      def mail_servers
        result.mail_servers
      end
    end
  end
end
