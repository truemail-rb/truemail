lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'truemail/version'

Gem::Specification.new do |spec|
  spec.name          = 'truemail'
  spec.version       = Truemail::VERSION
  spec.authors       = ['Vladislav Trotsenko']
  spec.email         = ['admin@bestweb.com.ua']

  spec.summary       = %(truemail)
  spec.description   = %(Configurable plain ruby email validator. Validate email by regexp, mx records and real email existence)
  spec.homepage      = 'https://github.com/rubygarage/truemail'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.4.5'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'overcommit', '>=0.46.0'
  spec.add_development_dependency 'reek', '>=5.3.1'
  spec.add_development_dependency 'rubocop', '~> 0.65.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.32.0'
  spec.add_development_dependency 'simplecov', '~> 0.16.1'
  spec.add_development_dependency 'bundler-audit', '>=0.6.1'
end
