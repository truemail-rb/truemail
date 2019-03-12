# frozen_string_literal: true

module Truemail
  module Validate
    class Regex < Truemail::Validate::Base
      ERROR = 'email does not match the regular expression'

      def run
        return true if success(Truemail.configuration.email_pattern.match?(result.email))
        add_error(Truemail::Validate::Regex::ERROR)
        false
      end
    end
  end
end
