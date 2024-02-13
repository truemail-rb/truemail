# frozen_string_literal: true

if ::RUBY_VERSION[/\A3\.3.+\z/]
  require 'simplecov'

  SimpleCov.minimum_coverage(100)
  SimpleCov.start { add_filter(%r{\A/spec/}) }
end
