# frozen_string_literal: true

module Truemail
  module ContextHelper
    def random_email
      faker.email
    end

    def random_ip_address
      faker.ip_v4_address
    end

    def random_domain_name
      faker.domain_name
    end

    def random_uniq_domain_name
      faker.unique.domain_name
    end

    private

    def faker
      Faker::Internet
    end
  end
end
