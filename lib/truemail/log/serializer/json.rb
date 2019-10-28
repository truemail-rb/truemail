# frozen_string_literal: true

module Truemail
  module Log
    module Serializer
      class Json < Truemail::Log::Serializer::Base
        def serialize
          result.to_json
        end
      end
    end
  end
end
