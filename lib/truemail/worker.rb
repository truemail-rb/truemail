# frozen_string_literal: true

module Truemail
  class Worker
    attr_reader :result

    def self.check(result)
      new(result).run
    end

    def initialize(result)
      @result = result
    end

    private

    def success(condition)
      result.success = condition || false
    end
  end
end
