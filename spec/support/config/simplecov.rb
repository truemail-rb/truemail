# frozen_string_literal: true

if ::RUBY_VERSION[/\A3\.3.+\z/]
  require 'simplecov'
  require 'simplecov-cobertura'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::CoberturaFormatter
    ]
  )
  SimpleCov.minimum_coverage(100)
  SimpleCov.start { add_filter(%r{\A/spec/}) }
end
