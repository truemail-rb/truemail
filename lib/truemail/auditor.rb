# frozen_string_literal: true

module Truemail
  class Auditor
    Result = Struct.new(:current_host_ip, :warnings, :configuration, keyword_init: true) do
      def initialize(warnings: {}, **args)
        super
      end
    end

    attr_reader :result

    def initialize(configuration:)
      @result = Truemail::Auditor::Result.new(configuration: configuration)
    end

    def run
      Truemail::Audit::Ip.check(result)
      self
    end
  end
end
