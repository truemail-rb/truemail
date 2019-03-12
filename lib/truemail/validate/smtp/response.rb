# frozen_string_literal: true

module Truemail
  module Validate
    class Smtp
      RESPONSE_ATTRS = %i[port_opened connection helo mailfrom rcptto errors].freeze

      Response = Struct.new(*RESPONSE_ATTRS, keyword_init: true) do
        def initialize(errors: {}, **args)
          super
        end
      end
    end
  end
end
