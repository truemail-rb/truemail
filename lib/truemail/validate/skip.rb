# frozen_string_literal: true

module Truemail
  module Validate
    class Skip < Truemail::Worker
      def run
        success(true)
      end
    end
  end
end
