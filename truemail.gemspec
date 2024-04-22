# frozen_string_literal: true

require_relative 'lib/truemail/version'

Gem::Specification.new do |spec|
  spec.name          = 'truemail'
  spec.version       = Truemail::VERSION
  spec.authors       = ['Vladislav Trotsenko']
  spec.email         = %w[admin@bestweb.com.ua]

  spec.summary       = %(Configurable framework agnostic plain Ruby email validator. Verify email via Regex, DNS, SMTP and even more)
  spec.description   = %(Configurable framework agnostic plain Ruby email validator. Verify email via Regex, DNS, SMTP and even more.)

  spec.homepage      = 'https://github.com/truemail-rb/truemail'
  spec.license       = 'MIT'

  spec.metadata = {
    'homepage_uri' => 'https://truemail-rb.org',
    'changelog_uri' => 'https://github.com/truemail-rb/truemail/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/truemail-rb/truemail',
    'documentation_uri' => 'https://truemail-rb.org/truemail-gem',
    'bug_tracker_uri' => 'https://github.com/truemail-rb/truemail/issues'
  }

  current_ruby_version = ::Gem::Version.new(::RUBY_VERSION)
  ffaker_version = current_ruby_version >= ::Gem::Version.new('3.0.0') ? '~> 2.23' : '~> 2.21'

  spec.required_ruby_version = '>= 2.5.0'
  spec.files = `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(bin|lib)/|.ruby-version|truemail.gemspec|LICENSE}) }
  spec.require_paths = %w[lib]

  spec.add_runtime_dependency 'net-smtp', '~> 0.5.0' if current_ruby_version >= ::Gem::Version.new('3.1.0')
  spec.add_runtime_dependency 'simpleidn', '~> 0.2.1'

  spec.add_development_dependency 'dns_mock', '~> 1.7', '>= 1.7.1'
  spec.add_development_dependency 'ffaker', ffaker_version
  spec.add_development_dependency 'json_matchers', '~> 0.11.1'
  spec.add_development_dependency 'rake', '~> 13.2', '>= 13.2.1'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'smtp_mock', '~> 1.4', '>= 1.4.1'
  spec.add_development_dependency 'truemail-rspec', '~> 1.3', '>= 1.3.1'
  spec.add_development_dependency 'webmock', '~> 3.23'
end
