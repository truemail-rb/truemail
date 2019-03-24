# frozen_string_literal: true

module Truemail
  module Validate
    class Base
      attr_reader :result

      def self.check(result)
        new(result).run
      end

      def initialize(result)
        @result = result
      end

      private

      def success(condition)
        result.success = condition
      end

      def add_error(message)
        result.errors[self.class.name.split('::').last.downcase.to_sym] = message
      end
    end
  end
end
