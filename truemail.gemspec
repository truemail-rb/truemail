# frozen_string_literal: true

require_relative 'lib/truemail/version'

Gem::Specification.new do |spec|
  spec.name          = 'truemail'
  spec.version       = Truemail::VERSION
  spec.authors       = ['Vladislav Trotsenko']
  spec.email         = ['admin@bestweb.com.ua']

  spec.summary       = %(truemail)
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

  spec.required_ruby_version = '>= 2.5.0'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| ::File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'net-smtp', '~> 0.3.2' if ::RUBY_VERSION >= '3.1.0'
  spec.add_runtime_dependency 'simpleidn', '~> 0.2.1'

  spec.add_development_dependency 'dns_mock', '~> 1.5', '>= 1.5.5'
  spec.add_development_dependency 'ffaker', '~> 2.21'
  spec.add_development_dependency 'json_matchers', '~> 0.11.1'
  spec.add_development_dependency 'rake', '~> 13.0', '>= 13.0.6'
  spec.add_development_dependency 'rspec', '~> 3.11'
  spec.add_development_dependency 'smtp_mock', '~> 1.2', '>= 1.2.2'
  spec.add_development_dependency 'truemail-rspec', '~> 0.9.2'
  spec.add_development_dependency 'webmock', '~> 3.18', '>= 3.18.1'
end
