# frozen_string_literal: true

module Truemail
  module Dns
    class Resolver
      WORKER_ACTIONS = %i[dns_lookup a_record a_records cname_records mx_records ptr_records].freeze

      class << self
        Truemail::Dns::Resolver::WORKER_ACTIONS.each do |worker_action|
          define_method(worker_action) do |argument, configuration:|
            Truemail::Dns::Worker.new(configuration.dns).public_send(worker_action, argument)
          end
        end
      end
    end
  end
end
