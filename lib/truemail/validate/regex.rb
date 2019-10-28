# frozen_string_literal: true

module Truemail
  module Validate
    class Regex < Truemail::Validate::Base
      ERROR = 'email does not match the regular expression'

      def run
        return true if success(match_regex_pattern?)
        add_error(Truemail::Validate::Regex::ERROR)
        false
      end

      private

      def match_regex_pattern?
        configuration.email_pattern.match?(result.email)
      end
    end
  end
end
