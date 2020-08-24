# frozen_string_literal: true

module Truemail
  module Log
    module Serializer
      class ValidatorJson < Truemail::Log::Serializer::ValidatorBase
        def serialize
          result.to_json
        end
      end
    end
  end
end
