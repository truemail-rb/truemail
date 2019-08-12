# frozen_string_literal: true

module Truemail
  module ConfigurationHelper
    def configuration_block(**configuration_settings)
      lambda do |config|
        configuration_settings.each do |attribute, value|
          config.public_send(:"#{attribute}=", value)
        end
      end
    end

    def create_configuration(**configuration_settings)
      configuration_settings[:verifier_email] = FFaker::Internet.email unless configuration_settings[:verifier_email]
      Truemail::Configuration.new(&configuration_block(configuration_settings))
    end
  end
end
