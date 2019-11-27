# frozen_string_literal: true

RSpec::Matchers.define(:match_to_ip_address) do
  match do |ip_address|
    IPAddr.new(ip_address) rescue false # rubocop:disable Style/RescueModifier
  end
end
