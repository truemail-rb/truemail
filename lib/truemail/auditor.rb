# frozen_string_literal: true

module Truemail
  class Auditor
    Result = Struct.new(:warnings, keyword_init: true) do
      def initialize(warnings: {}, **args)
        super
      end
    end

    attr_reader :result

    def initialize
      @result = Truemail::Auditor::Result.new
      run
    end

    private

    def run
      Truemail::Audit::Ptr.check(result)
    end
  end
end
