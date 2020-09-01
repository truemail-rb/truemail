# frozen_string_literal: true

module Truemail
  class Auditor < Truemail::Executor
    Result = Struct.new(:current_host_ip, :warnings, :configuration, keyword_init: true) do
      def initialize(warnings: {}, **args)
        super
      end
    end

    def initialize(configuration:)
      @result = Truemail::Auditor::Result.new(configuration: configuration)
    end

    def run
      Truemail::Audit::Ip.check(result)
      self
    end

    def as_json
      Truemail::Log::Serializer::AuditorJson.call(self)
    end
  end
end
