module Truemail
  module ConfigurationHelper
    def configuration_block(**configuration_settings)
      lambda do |config|
        configuration_settings.each do |attribute, value|
          config.public_send(:"#{attribute}=", value)
        end
      end
    end
  end
end
