# frozen_string_literal: true

module Truemail
  module Dns
    PunycodeRepresenter = Class.new do
      require 'simpleidn'

      def self.call(email)
        return unless email.is_a?(::String)
        return email if email.ascii_only?
        user, domain = email.split('@')
        "#{user}@#{SimpleIDN.to_ascii(domain.downcase)}"
      end
    end
  end
end
