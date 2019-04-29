# frozen_string_literal: true

# rubocop:disable Style/RescueModifier
RSpec::Matchers.define(:match_to_ip_address) do
  match do |ip_address|
    IPAddr.new(ip_address) rescue false
  end
end
