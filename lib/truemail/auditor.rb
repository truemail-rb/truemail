# frozen_string_literal: true

module Truemail
  class Auditor
    Result = Struct.new(:warnings, keyword_init: true) do
      def initialize(warnings: {}, **args)
        super
      end
    end

    def self.run
      new.run
    end

    def result
      @result ||= Truemail::Auditor::Result.new
    end

    def run
      Truemail::Audit::Ptr.check(result)
      self
    end
  end
end
