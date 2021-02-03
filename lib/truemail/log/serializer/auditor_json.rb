# frozen_string_literal: true

module Truemail
  module Log
    module Serializer
      class AuditorJson < Truemail::Log::Serializer::Base
        def serialize
          result.to_json
        end

        private

        def result
          @result ||=
            {
              date: ::Time.now,
              current_host_ip: executor_result.current_host_ip,
              warnings: warnings(executor_result.warnings),
              configuration: configuration
            }
        end
      end
    end
  end
end
