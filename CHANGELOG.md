# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0] - 2026.10.16

### Fixed

- Fixed MX validation accepting IDNA-mapped confusable/fullwidth domains (e.g. `somebody@reready.cｏ` mapped to ASCII `reready.co` without `xn--` labels). Thanks to [@dan-jensen](https://github.com/dan-jensen) for the report

### Added

- Added Codecov coverage reporting (`simplecov-cobertura`, Codecov CLI upload)
- Added Ruby 4.0 CircleCI pipeline

### Updated

- Updated runtime/development dependencies
- Updated `circleci`/`simplecov`/`commitspell`/`rubocop`/`markdownlint` configs
- Updated project documentation
- Updated gem version

### Removed

- Removed CodeClimate integration (`.codeclimate.yml`, `cc-test-reporter`, maintainability badge)

## [3.3.1] - 2024.04.23

### Updated

- Updated runtime/development dependencies
- Updated `codeclimate`/`reek` configs
- Updated gem version

## [3.3.0] - 2024.02.26

### Added

- Added the ability to use a custom logger instance in the event logger. Thanks to [@n-rodriguez](https://github.com/n-rodriguez) for the report
- Added `Truemail::Logger::Builder`, tests

### Updated

- Updated `Truemail::Configuration#logger=`, tests
- Updated `Truemail::Logger`, tests
- Updated `circleci`/`lefthook` configs
- Updated gem version

### Removed

- Removed `Truemail::Configuration#logger_options`

## [3.2.0] - 2024.02.24

### Added

- Added the ability to use a custom logger in the event logger
- Added `commitspell` linter

### Updated

- Updated `Truemail::Configuration`
- Updated `Truemail::Logger`
- Updated development dependencies
- Updated `circleci`/`lefthook` configs
- Updated gem version

## [3.1.2] - 2024.02.15

### Added

- Added support for the latest Ruby 3.3.0
- Added `changelog` linter

### Updated

- Updated development dependencies
- Updated `circleci`/`rspec`/`codeclimate` configs
- Updated gem version

## [3.1.1] - 2024.01.27

### Updated

- Updated `valid?` predicate. Thanks to [@SofiaSousa](https://github.com/SofiaSousa) for the report
- Updated runtime/development dependencies
- Updated `codeclimate` config
- Updated gem version

## [3.1.0] - 2023.10.31

### Updated

- Updated runtime/development dependencies
- Updated gemspecs
- Updated RSpec helpers namespaces
- Updated `codeclimate`/`reek` configs
- Updated gem version

## [3.0.9] - 2023.07.19

### Fixed

- Fixed `Truemail::RegexConstant::REGEX_DOMAIN`. Thanks to [@Sybe](https://github.com/Sybe) for the report

### Updated

- Updated `Truemail::Validate::Mx#hosts_from_cname_records?`
- Updated `Truemail::Validate::Smtp#not_includes_user_not_found_errors?`
- Updated development dependencies
- Updated gemspecs
- Updated `codeclimate` config
- Updated gem version

## [3.0.8] - 2023.05.11

### Updated

- Updated development dependencies
- Updated gemspecs
- Updated `codeclimate` config
- Updated gem version

## [3.0.7] - 2023.03.11

### Updated

- Updated development dependencies
- Updated gemspecs
- Updated `codeclimate` config
- Updated gem version

## [3.0.6] - 2023.02.17

### Updated

- Updated development dependencies
- Updated gemspecs
- Updated `rubocop`/`codeclimate`/`circleci` configs
- Updated gem version

## [3.0.5] - 2023.01.12

### Added

- Added support for the latest Ruby 3.2.0
- Added `changelog` linter

### Updated

- Updated development dependencies
- Updated gemspecs
- Updated `CI` release script
- Updated `rubocop`/`codeclimate`/`lefthook`/`circleci` configs
- Updated gem version

## [3.0.4] - 2022.12.16

### Fixed

- Fixed linter issues

### Added

- Added `cspell` linter
- Added `markdownlint` linter
- Added `shellcheck` linter

### Updated

- Updated gemspecs
- Updated `rubocop`/`codeclimate`/`lefthook`/`circleci` configs
- Updated gem version

### Removed

- `mdl` linter, config

## [3.0.3] - 2022.12.05

### Added

- Added a new bunch of project linters
- Added automatic deployment to RubyGems
- Added automatic creation of release notes on GitHub

### Updated

- Updated gemspecs
- Updated `codeclimate`/`circleci` configs
- Updated gem development dependencies
- Updated gem version

### Removed

- Removed `overcommit` dependency

## [3.0.2] - 2022.11.21

### Updated

- Updated gem runtime/development dependencies
- Updated gemspecs, `circleci` config
- Updated `rubocop`/`codeclimate` configs
- Updated gem version

## [3.0.1] - 2022.11.01

### Fixed

- Fixed wrong semantic version comparison in the gemspec runtime dependency definition

### Updated

- Updated RSpec helpers
- Updated gemspecs, `circleci` config
- Updated gem version

## [3.0.0] - 2022.10.24

### Added

- Added the ability to specify whitelisted/blacklisted emails by exact match

```ruby
Truemail.configure do |config|
  # Optional parameter. Validation of a whitelisted email will always return true.
  # Other validations will not be performed, even if defined in validation_type_for.
  # It defaults to an empty array.
  config.whitelisted_emails = %w[user@somedomain1.com user@somedomain2.com]

  # Optional parameter. Validation of a blacklisted email will always return false.
  # Other validations will not be performed, even if defined in validation_type_for.
  # It defaults to an empty array.
  config.blacklisted_emails = %w[user@somedomain3.com user@somedomain4.com]
end
```

### Updated

- Updated `Truemail::Configuration`, tests
- Updated namespace from `Truemail::Validate::DomainListMatch` to `Truemail::Validate::ListMatch`
- Updated `Truemail::Validator#run`, tests
- Updated `Truemail::Log::Serializer::ValidatorJson`, tests
- Updated `Truemail::Log::Serializer::ValidatorText`, tests
- Updated `Truemail::Log::Serializer::AuditorJson`, tests
- Updated schemas, gemspecs, `circleci`/`codeclimate` config
- Updated docs, gem version

## [2.7.5] - 2022.10.10

### Updated

- Updated gemspecs, `circleci` config
- Updated `codeclimate` config
- Updated gem version

## [2.7.4] - 2022.08.16

### Updated

- Updated gemspecs, `circleci` config
- Updated `rubocop`/`codeclimate` configs
- Updated gem version

## [2.7.3] - 2022.05.31

### Updated

- Updated gemspecs, `circleci` config
- Updated `rubocop`/`codeclimate` configs
- Updated gem version

## [2.7.2] - 2022.04.02

### Updated

- Updated gemspecs, `circleci` config
- Updated `rubocop`/`codeclimate` configs
- Updated git templates
- Updated gem version

## [2.7.1] - 2022.03.02

### Updated

- Updated truemail gemspecs
- Updated gem version

## [2.7.0] - 2022.02.23

### Added

- Added the ability to specify the SMTP port number

### Updated

- Updated truemail gemspec
- Updated gem version

## [2.6.6] - 2022.02.09

### Added

- Added development environment guide docs

### Updated

- Updated truemail gemspec
- Updated gem version

## [2.6.5] - 2022.02.09

### Added

- Added a gemspec with the latest dependencies for the latest Ruby environment

### Updated

- Updated default gemspec, ruby-version
- Updated `circleci` Ruby env flow
- Updated gem version

### Fixed

- Fixed redefinition of built-in implementations caused by using stdlib as external dependencies

## [2.6.4] - 2022.02.09

### Fixed

- Fixed redefinition of built-in implementations caused by using stdlib as external dependencies. Thanks to [@adzap](https://github.com/adzap) for the report.

## [2.6.3] - 2022.02.07

### Updated

- Updated gem `net-smtp` runtime dependency
- Updated gem development dependencies
- Updated gem version

## [2.6.2] - 2022.01.19

### Updated

- Updated tests
- Updated gem development dependencies
- Updated gem version

## [2.6.1] - 2022.01.04

### Fixed

- Fixed redefinition of built-in implementations caused by using stdlib as external dependencies. Thanks to [@allard](https://github.com/allard) for the report.

### Updated

- Updated `Truemail::Validate::Smtp::Request::Session#initialize`, `Truemail::Validate::Smtp::Request::Session#start`, tests
- Updated `rubocop`/reek configs
- Updated gem docs, version

## [2.6.0] - 2021.12.28

### Added

- Added Ruby 3.1.x compatibility
- Added `Truemail::Validate::Smtp::Request::Session`, a `Net::SMTP` wrapper, tests

### Updated

- Updated `Truemail::Validate::Smtp::Request#session`, `Truemail::Validate::Smtp::Request#run`, tests
- Updated `rubocop`/reek/`codeclimate`/`circleci` configs
- Updated gem runtime/development dependencies
- Updated gem docs, version

## [2.5.4] - 2021.12.03

### Fixed

- Fixed `Net::SMTP#start` Ruby 2.x compatibility. Thanks to [@evserykh](https://github.com/evserykh) for the bug report.

### Updated

- Updated `Truemail::Validate::Smtp::Request#run`
- Updated `rubocop`/`codeclimate` configs
- Updated gem development dependencies
- Updated gem docs, version

## [2.5.3] - 2021.11.08

### Fixed

- Fixed Ruby 3.0 stdlib SMTP client SSL certificate verification issues for cases when an IP address is used as the MX host. Thanks to [@esb](https://github.com/esb) for the bug report.

### Updated

- Updated `Truemail::Validate::Smtp::Request#run`
- Updated gem development dependencies
- Updated gem version

## [2.5.2] - 2021.10.06

### Fixed

- Fixed `Truemail::RegexConstant::REGEX_EMAIL_PATTERN` behavior with a double `@` in the email. Thanks to [@your-favorite-dev](https://github.com/your-favorite-dev) for the bug report.

### Updated

- Updated tests
- Updated gem development dependencies
- Updated gem version

## [2.5.1] - 2021.10.01

### Updated

- Updated gem development dependencies
- Updated gem version

## [2.5.0] - 2021.09.01

### Updated

Optimized the DNS (MX) validation flow. Removed a needless DNS request for the case when a custom email pattern is defined and the email being validated includes an invalid domain name.

- Updated `Truemail::Validate::Mx#run`, tests
- Updated gem development dependencies
- Updated gem documentation, version

## [2.4.9] - 2021.08.20

### Updated

- Updated `Truemail::Validate::DomainListMatch#email_domain`, tests
- Updated `Truemail::Validate::Mx#domain`, tests
- Updated gem development dependencies
- Updated gem version

## [2.4.8] - 2021.08.12

### Updated

- Updated gem development dependencies
- Updated gem version

### Changed

- Switched the `faker` development dependency to `ffaker`

## [2.4.7] - 2021.08.09

### Updated

- Updated gem codebase, refactored `Truemail::RspecHelper::Context`
- Updated tests with `Truemail::RspecHelper::Dns#dns_mock_gateway`
- Updated gem development dependencies
- Updated gem version

## [2.4.6] - 2021.07.10

### Fixed

- Fixed wrong domain punycode extraction in the DNS validation layer

### Updated

- Updated gem codebase, restored `Truemail::RegexConstant::REGEX_DOMAIN_FROM_EMAIL`
- Updated tests

## [2.4.5] - 2021.07.09

### Removed

- `Truemail::RegexConstant::REGEX_DOMAIN_FROM_EMAIL`

### Updated

- `Truemail::Validate::Mx`
- Updated gem development dependencies
- Updated gem version

## [2.4.4] - 2021.06.29

### Updated

Allowed special characters in email user names (following [RFC 3696](https://datatracker.ietf.org/doc/html/rfc3696#page-6)) in the default regex email pattern.

- Updated `Truemail::RegexConstant::REGEX_EMAIL_PATTERN`, tests
- Updated gem development dependencies
- Updated `rubocop`/`codeclimate` config
- Updated gem documentation, version

## [2.4.3] - 2021.06.15

### Updated

- Updated gem development dependencies
- Updated `rubocop`/`codeclimate` config
- Updated gem documentation, version

## [2.4.2] - 2021.05.13

### Fixed

- Fixed a security vulnerability in bundler ([CVE-2019-3881](https://github.com/advisories/GHSA-g98m-96g9-wfjq))
- Fixed test coverage issues

### Updated

- Updated gem development dependencies
- Updated `simplecov`/`circleci` config
- Updated gem documentation, version

## [2.4.1] - 2021.05.05

### Updated

- `Truemail::Validate::MxBlacklist`, tests
- Updated gem development dependencies
- Updated gem documentation, version

## [2.4.0] - 2021.04.28

### Added

- Implemented `MxBlacklist` validation. This layer checks mail servers against a predefined list of blacklisted IP addresses and can be used as part of DEA ([disposable email address](https://en.wikipedia.org/wiki/Disposable_email_address)) validation.

```ruby
Truemail.configure do |config|
  # Optional parameter. With this option Truemail will filter out unwanted MX servers using
  # a predefined list of IP addresses. It can be used as part of DEA (disposable email
  # address) validation. It defaults to an empty array.
  config.blacklisted_mx_ip_addresses = ['1.1.1.1', '2.2.2.2']
end
```

### Changed

- Updated `Truemail::Core`, tests
- Updated `Truemail::Configuration`, tests
- Updated `Truemail::Validator`
- Updated `Truemail::Validate::Smtp`, tests
- Updated `Truemail::Log::Serializer::Base`, dependent tests
- Updated `Truemail::Log::Serializer::ValidatorText`, tests
- Updated gem development dependencies
- Updated gem documentation, changelog, version

## [2.3.4] - 2021.04.16

### Fixed

Fixed a bug that made it impossible to use a valid DNS port number. Validation of DNS ports in the range `1..65535` now works as expected.

- Updated `Truemail::RegexConstant::REGEX_PORT_NUMBER`, tests
- Updated gem documentation
- Moved the `circleci` config to `.circleci/config.yml`

## [2.3.3] - 2021.04.14

### Changed

- Updated gem development dependencies
- Updated `rubocop`/`codeclimate` config
- Updated `circleci` config

## [2.3.2] - 2021.03.08

### Changed

- Updated gem development dependencies
- Updated `rubocop`/`codeclimate` config

## [2.3.1] - 2021.02.26

### Changed

- Updated gem development dependencies
- Updated `rubocop`/`codeclimate` config
- Updated tests

## [2.3.0] - 2021.02.05

### Added

- Ability to use a custom DNS gateway. Thanks to [@le0pard](https://github.com/le0pard) for the great idea and to [@verdi8](https://github.com/verdi8) for the feature [request](https://github.com/truemail-rb/truemail/issues/126).

```ruby
Truemail.configure do |config|
  # Optional parameter. This option makes Truemail use custom DNS gateways when it
  # interacts with DNS. If you don't specify a nameserver port, Truemail will use the default
  # DNS TCP/UDP port 53. By default Truemail uses the DNS gateway from the system settings,
  # and this option is an empty array.
  config.dns = ['10.0.0.1', '10.0.0.2:5300']
end
```

- Added `Truemail::Dns::Resolver`
- Added `Truemail::Dns::Worker`

### Changed

- Updated `Truemail::Configuration`, tests
- Updated `Truemail::Validate::Mx`, tests
- Updated `Truemail::Audit::Base`
- Updated `Truemail::Audit::Dns`, tests
- Updated `Truemail::Audit::Ptr`, tests
- Updated `Truemail::Log::Serializer::Base`, dependent tests
- Updated namespaces for stdlib classes
- Updated gem development dependencies
- Updated linters/`codeclimate` configs
- Updated gem runtime/development dependencies
- Updated gem documentation, changelog, version

## [2.2.3] - 2021.01.12

### Fixed

Removed a needless `Timeout.timeout` block in `Truemail::Validate::Smtp::Request#check_port` and replaced `TCPSocket` with `Socket`, which has native timeout detection. Thanks to [@wikiti](https://github.com/wikiti) for the idea, for testing in production, and for the clean PR [#127](https://github.com/truemail-rb/truemail/pull/127).

### Changed

- Updated `Truemail::Validate::Smtp::Request`
- Updated gem development dependencies
- Updated `rubocop`, reek configs

## [2.2.2] - 2020.12.30

### Changed

- Updated gem development dependencies
- Updated `rubocop` config

## [2.2.1] - 2020.12.06

### Fixed

- Filtered out ASCII-8BIT chars from serialized SMTP response errors. Fixed `Encoding::UndefinedConversionError` in `Truemail::Log::Serializer::ValidatorJson#serialize`. Thanks to [@eni9889](https://github.com/eni9889) for the report
- Added the missing `smtp_fail_fast` attribute to serialized validator and auditor results

### Added

- Added `Truemail::Log::Serializer::ValidatorBase#replace_invalid_chars`

### Changed

- Updated `Truemail::Log::Serializer::Base`
- Updated `Truemail::Log::Serializer::ValidatorBase`
- Updated gem development dependencies

## [2.2.0] - 2020.12.01

Ability to use fail-fast behavior for the SMTP validation layer. When `smtp_fail_fast = true`, `truemail` ends the SMTP validation session after the first attempt on the first MX server in any failure case (network connection/timeout error, SMTP validation error). This feature helps reduce the total time of an SMTP validation session to about 1 second.

### Added

- Added `Truemail::Configuration#smtp_fail_fast`
- Added `Truemail::Validate::Smtp#smtp_fail_fast?`
- Added `Truemail::Validate::Smtp#filtered_mail_servers_by_fail_fast_scenario`

### Changed

- Updated `Truemail::Validate::Smtp#attempts`
- Updated `Truemail::Validate::Smtp#establish_smtp_connection`
- Updated gem documentation

It's a configurable, optional setting:

```ruby
Truemail.configure do |config|
  config.smtp_fail_fast = true # it defaults to false
end
```

Thanks to [@wikiti](https://github.com/wikiti) for the timeout reports.

## [2.1.0] - 2020.11.21

Only unique IP addresses are now collected for target mail servers. This update reduces email validation time for the case when the remote server has closed the connection, by avoiding connection attempts to servers with the same IP address.

### Changed

- Updated `Truemail::Validate::Mx#fetch_target_hosts`

## [2.0.2] - 2020.11.14

### Fixed

Fixed the timeout time units in the `Setting global configuration` section of the Truemail documentation. Thanks to [@wikiti](https://github.com/wikiti) for the report.

### Changed

- Refactored `Truemail::RegexConstant::REGEX_EMAIL_PATTERN`
- Updated gem development dependencies
- Updated gem documentation

## [2.0.1] - 2020.10.20

### Changed

- Updated gem development dependencies
- Updated gem documentation

## [2.0.0] - 2020.10.19

### Fixed

Fixed SMTP connection errors: invalid `HELO` hostname (`localhost`), duplicate `HELO` (`verifier domain`). Thanks to [@nenoganchev](https://github.com/nenoganchev) for the report.

### Changed

- Updated `Truemail::Validate::Smtp::Request#run`
- Updated `Truemail::Validate::Smtp::Request#session_data`
- Updated `Truemail::Validate::Smtp::Response`

`helo` is now a `Boolean` instead of a `Net::SMTP::Response` instance. It was changed because `helo` is sent during SMTP session initialization (`Net::SMTP.new.start`), and `helo` is always `true` if the session comes up fine. Also, the `helo` response is no longer logged as an error when that happens. Example of a `Truemail::Validate::Smtp::Response` instance from version 2.x:

```ruby
#<struct Truemail::Validate::Smtp::Response:0x00007fa74704cd10
  port_opened=true,
  connection=true,
  helo=true, # Returns Boolean instead of Net::SMTP::Response instance
  mailfrom=false,
  rcptto=nil,
  errors={:mailfrom=>"server response timeout"}>
```

## [1.9.2] - 2020.10.02

### Added

- `Truemail::TypeError`
- Error handling for invalid input email types

### Changed

- Updated `Truemail.validate`
- Updated `Truemail.valid?`

## [1.9.1] - 2020.09.21

### Changed

Migrated to updated Ruby 2.7.x syntax.

- Updated `Truemail::Configuration#logger=`

## [1.9.0] - 2020.09.01

### Added

- Ability to represent a `Truemail::Auditor` instance as JSON directly
- `Truemail::Log::Serializer::AuditorJson`

### Changed

- `Truemail::Auditor`, `Truemail::Validator`
- Serializer namespaces
- gem development dependencies
- gem documentation

```ruby
Truemail.host_audit.as_json

=>
# Serialized Truemail::Auditor instance
{
  "date": "2020-08-31 22:33:43 +0300",
  "current_host_ip": "127.0.0.1",
  "warnings": {
    "dns": "A record of verifier domain does not refer to current host IP address", "ptr": "PTR record does not refer to current verifier domain"
  },
 "configuration": {
    "validation_type_by_domain": null,
    "whitelist_validation": false,
    "whitelisted_domains": null,
    "blacklisted_domains": null,
    "not_rfc_mx_lookup_flow": false,
    "smtp_safe_check": false,
    "email_pattern": "default gem value",
    "smtp_error_body_pattern": "default gem value"
  }
}
```

## [1.8.0] - 2020.06.21

### Added

Separated the audit features for the verifier host.

- `Truemail::Audit::Ip`
- `Truemail::Audit::Dns`

```ruby
Truemail.host_audit

=> #<Truemail::Auditor:0x00005580df358828
@result=
  #<struct Truemail::Auditor::Result
    current_host_ip="127.0.0.1",
    warnings={
      :dns=>"a record of verifier domain does not refer to current host ip address",
      :ptr=>"ptr record does not refer to current verifier domain"
    },
    configuration=
    #<Truemail::Configuration:0x00005615e86327a8
      @blacklisted_domains=[],
      @connection_attempts=2,
      @connection_timeout=2,
      @default_validation_type=:smtp,
      @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
      @response_timeout=2,
      @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
      @not_rfc_mx_lookup_flow=false,
      @smtp_safe_check=false,
      @validation_type_by_domain={},
      @verifier_domain="example.com",
      @verifier_email="verifier@example.com",
      @whitelist_validation=false,
      @whitelisted_domains=[]>
```

### Changed

- `Truemail::Auditor`
- `Truemail::Auditor::Result`
- `Truemail::Audit::Base`
- `Truemail::Audit::Ptr`
- `Truemail::VERSION`
- gem documentation

## [1.7.1] - 2020.05.10

### Added

- Ability to show the `not_rfc_mx_lookup_flow` attribute in the serialized validation result

```ruby
Truemail.validate('nonexistent_email@bestweb.com.ua').as_json

=>
# Serialized Truemail::Validator instance
{
  "date": "2020-05-10 10:00:00 +0200",
  "email": "nonexistent_email@bestweb.com.ua",
  "validation_type": "smtp",
  "success": false,
  "errors": {
    "smtp": "smtp error"
  },
  "smtp_debug": [
    {
      "mail_host": "213.180.193.89",
      "port_opened": true,
      "connection": true,
      "errors": {
        "rcptto": "550 5.7.1 No such user!\n"
      }
    }
  ],
  "configuration": {
    "validation_type_by_domain": null,
    "whitelist_validation": false,
    "whitelisted_domains": null,
    "blacklisted_domains": null,
    "not_rfc_mx_lookup_flow": false,
    "smtp_safe_check": false,
    "email_pattern": "default gem value",
    "smtp_error_body_pattern": "default gem value"
  }
}
```

### Changed

- `Truemail::Log::Serializer::Base`
- `Truemail::VERSION`
- gem documentation

## [1.7.0] - 2020.05.09

### Added

- Ability to use a non-RFC MX lookup flow (only MX and Null MX records are checked on the DNS validation layer, skipping the CNAME and A record fallbacks)

```ruby
Truemail.configure do |config|
  # Optional parameter. This option enables the non-RFC MX lookup flow.
  # It means that only MX and Null MX records will be checked on the DNS validation layer.
  # This option is disabled by default.
  config.not_rfc_mx_lookup_flow = true
end
```

### Changed

- `Truemail.configuration`
- `Truemail::Validate::Mx`
- `Truemail::VERSION`
- gem development dependencies
- gem documentation

## [1.6.1] - 2020.03.23

### Changed

- `Truemail.configuration`
- `Truemail::ArgumentError`
- `Truemail::Audit::Ptr`
- `Truemail::VERSION`
- gem development dependencies
- gem documentation

### Removed

`Truemail::Configuration.retry_count` was deprecated, and the alias for this method has been removed. Please use `Truemail::Configuration.connection_attempts` instead.

## [1.6.0] - 2020-02-01

### Added

- Ability to represent a `Truemail::Validator` instance as JSON directly

### Changed

- gem development dependencies
- gem documentation

## [1.5.1] - 2020-01-20

### Changed

- gem development dependencies
- gem documentation

## [1.5.0] - 2019-12-29

### Added

- Support for internationalized emails ([EAI](https://en.wikipedia.org/wiki/International_email)). Now you can validate emails like `dörte@sörensen.de`, `квіточка@пошта.укр`, `alegría@mañana.es`

### Changed

- `Truemail::RegexConstant::REGEX_DOMAIN`
- `Truemail::RegexConstant::REGEX_EMAIL_PATTERN`
- `Truemail::Validator::Result`
- `Truemail::Validate::Mx#run`
- `Truemail::Validate::Smtp#establish_smtp_connection`
- gem runtime dependencies
- gem development dependencies
- gem documentation
- linter configs

## [1.4.2] - 2019-11-27

### Changed

- `Truemail::Configuration`
- gem development dependencies
- linter configs

## [1.4.1] - 2019-11-20

### Changed

- gem development dependencies
- gem documentation
- linter configs

### Removed

- Truemail RSpec helpers (moved to the independent gem [`truemail-rspec`](https://github.com/truemail-rb/truemail-rspec))

## [1.4.0] - 2019-10-28

### Added

- Event logger (ability to output validation logs to stdout/file)
- JSON serializer for validator instance
- [Changelog](CHANGELOG.md)
- [Logo](https://repository-images.githubusercontent.com/173723932/6dffee00-e88e-11e9-94b6-c97aacc0df00)

The Truemail gem can output tracking events to stdout, to a file, or both. Please note that at least one of the outputs must be configured. The default tracking event is `:error`.

#### Available tracking events

- `:all`, all detected events, including successful validations
- `:unrecognized_error`, unrecognized errors only (when `smtp_safe_check = true` and the SMTP server does not return an explicit answer that the email does not exist)
- `:recognized_error`, recognized errors only
- `:error`, recognized and unrecognized errors only

```ruby
Truemail.configure do |config|
  config.logger = { tracking_event: :all, stdout: true, log_absolute_path: '/home/app/log/truemail.log' }
end
```

Also, starting from this version, Truemail has a built-in JSON serializer for `Truemail::Validator` instances, so you can represent your email validation result as JSON.

```ruby
Truemail::Log::Serializer::Json.call(Truemail.validate('nonexistent_email@bestweb.com.ua'))
```

### Changed

- `Truemail::Configuration`
- `Truemail::Validator`
- `Truemail::Validate::Regex`
- `Truemail::VERSION`
- gem documentation
- gem description

## [1.3.0] - 2019-09-16

### Added

- Ability to create a new `Truemail::Configuration` instance with a block
- `Truemail::Validate::Smtp::Request::Configuration`

### Changed

- `Truemail::Wrapper`
- `Truemail::Validate::Base`
- `Truemail::Validator`
- `Truemail::Validator::Result`
- `Truemail::Validate::Regex`
- `Truemail::Validate::Mx`
- `Truemail::Validate::Smtp`
- `Truemail::Validate::Smtp::Request`
- `Truemail::Audit::Base`
- `Truemail::Auditor`
- `Truemail::Audit::Ptr`
- `::Truemail` module
- `Truemail::VERSION`
- gem documentation
- gem description

## [1.2.1] - 2019-06-27

### Fixed

- Removed memoization from ```DomainListMatch#whitelisted_domain?```

### Changed

- `Truemail::VERSION`
- gem documentation

## [1.2.0] - 2019-06-26

### Added

- Configurable option: validation for whitelisted domains only.

When the email domain is whitelisted and ```whitelist_validation``` is set to ```true```, validation is passed on to the other validators. Validation of an email whose domain is not whitelisted will always return ```false```.

```ruby
Truemail.configure do |config|
  config.verifier_email = 'verifier@example.com'
  config.whitelisted_domains = ['white-domain.com']
  config.whitelist_validation = true
end
```

#### Email has a whitelisted domain

```ruby
Truemail.validate('email@white-domain.com', with: :regex)

#<Truemail::Validator:0x000055b8429f3490
  @result=#<struct Truemail::Validator::Result
    success=true,
    email="email@white-domain.com",
    domain=nil,
    mail_servers=[],
    errors={},
    smtp_debug=nil>,
  @validation_type=:regex>
```

#### Email does not have a whitelisted domain

```ruby
Truemail.validate('email@domain.com', with: :regex)

#<Truemail::Validator:0x000055b8429f3490
  @result=#<struct Truemail::Validator::Result
    success=false,
    email="email@domain.com",
    domain=nil,
    mail_servers=[],
    errors={},
    smtp_debug=nil>,
  @validation_type=:blacklist>
```

### Changed

- `Truemail::VERSION`
- gem documentation

## [1.1.0] - 2019-06-18

### Added

- Configurable default validation type, [issue details](https://github.com/truemail-rb/truemail/issues/48)

You can predefine the default validation type for `Truemail.validate('email@email.com')` calls made without the `with:` parameter. Available validation types: `:regex`, `:mx`, `:smtp`. The default validation type remains `:smtp`.

```ruby
Truemail.configure do |config|
  config.verifier_email = 'verifier@example.com'
  config.default_validation_type = :mx
end
```

### Changed

- `Truemail::VERSION`
- gem documentation

## [1.0.1] - 2019-06-08

### Added

- Result validation type marker for domain list match check

```ruby
Truemail.validate('email@white-domain.com')

#<Truemail::Validator:0x000055b8429f3490
  @result=#<struct Truemail::Validator::Result
    success=true,
    email="email@white-domain.com",
    domain=nil,
    mail_servers=[],
    errors={},
    smtp_debug=nil>,
  @validation_type=:whitelist>

Truemail.validate('email@black-domain.com')

#<Truemail::Validator:0x000023y8429f3493
  @result=#<struct Truemail::Validator::Result
    success=false,
    email="email@black-domain.com",
    domain=nil,
    mail_servers=[],
    errors={},
    smtp_debug=nil>,
  @validation_type=:blacklist>
```

### Changed

- `Truemail::VERSION`
- gem documentation

## [1.0] - 2019-06-04

### Added

- Domain whitelist/blacklist feature. Other validations will not be performed, even if defined in `validation_type_for`.

```ruby
Truemail.configure do |config|
  # Optional parameter. Validation of an email with a whitelisted domain
  # will always return true.
  config.whitelisted_domains = ['somedomain1.com', 'somedomain2.com']

  # Optional parameter. Validation of an email with a blacklisted domain
  # will always return false.
  config.blacklisted_domains = ['somedomain1.com', 'somedomain2.com']
end
```

and

```ruby
Truemail.configuration.whitelisted_domains = ['somedomain1.com', 'somedomain2.com']
Truemail.configuration.blacklisted_domains = ['somedomain1.com', 'somedomain2.com']
```

### Removed

- `:skip` validation type for `validation_type_for`

### Fixed

- Error key in `lower_snake_case`

### Changed

- `Truemail::VERSION`
- gem documentation

## [0.2] - 2019-05-23

### Added

- Skipping validation by domain via the `validation_type_for` configuration option:

```ruby
Truemail.configure do |config|
  config.validation_type_for = { 'somedomain.com' => :skip }
end
```

and

```ruby
Truemail.configuration.validation_type_for = { 'somedomain.com' => :skip }
```

### Changed

- `Truemail::VERSION`
- gem documentation

## [0.1.10] - 2019-05-10

### Added

- SMTP error body configurable option, [issue details](https://github.com/truemail-rb/truemail/issues/19)

### Changed

- `Truemail::VERSION`
- gem documentation

## [0.1.9] - 2019-04-29

### Fixed

- Empty PTR constant

## [0.1.8] - 2019-04-29

### Added

- Reverse trace, [issue details](https://github.com/truemail-rb/truemail/issues/18)

### Fixed

- Behavior of current host address resolver, [issue details](https://github.com/truemail-rb/truemail/issues/18)

### Changed

- `Truemail::VERSION`
- gem documentation

## [0.1.7] - 2019-04-17

### Added

- PTR record audit, [issue details](https://github.com/truemail-rb/truemail/issues/18)

### Changed

- `Truemail::VERSION`
- gem documentation

## [0.1.6] - 2019-04-08

### Added

- MX logic following [RFC 7505](https://tools.ietf.org/html/rfc7505), null MX record support, [issue details](https://github.com/truemail-rb/truemail/issues/27)
- [Contributing guideline](CONTRIBUTING.md)

### Fixed

- Multihomed MX record support, [issue details](https://github.com/truemail-rb/truemail/issues/28)

### Changed

- `Truemail::VERSION`
- gem documentation

## [0.1.5] - 2019-04-05

### Added

- Retries for `Truemail::Validate::Smtp` for cases when there is one MX server

### Changed

- `Truemail::Configuration` class, please use `.connection_attempts` instead of `.retry_count`
- `Truemail::VERSION`
- gem documentation

## [0.1.4] - 2019-04-01

### Added

- Checking for A record presence if `MX` and `CNAME` records do not exist, [issue details](https://github.com/truemail-rb/truemail/issues/10)
- Handling of `CNAME` records, [issue details](https://github.com/truemail-rb/truemail/issues/11)
- Checking the A record if `MX` and `CNAME` records are not found, [issue details](https://github.com/truemail-rb/truemail/issues/12)
- Support for multihomed MX records, conversion of host names to IPs, [issue details](https://github.com/truemail-rb/truemail/issues/17)
- Timeout configuration for DNS resolver, [issue details](https://github.com/truemail-rb/truemail/issues/13)
- `.valid?` helper

### Changed

- `Truemail::VERSION`
- gem documentation

## [0.1.3] - 2019-03-27

### Added

- Independent domain name extractor for `Truemail::Validate::Mx#run`

### Fixed

- Default `REGEX_EMAIL_PATTERN`, [issue details](https://github.com/truemail-rb/truemail/issues/7)
  - the local part of the address can't start with a dot or a special symbol
  - the local part of the address can include the ```+``` symbol
- Default `REGEX_DOMAIN_PATTERN`, [issue details](https://github.com/truemail-rb/truemail/issues/8)
  - TLD size increased to 63 characters
- Case-sensitive domain names, [issue details](https://github.com/truemail-rb/truemail/issues/9)

### Changed

- `Truemail::VERSION`
- gem documentation

## [0.1.0] - 2019-03-26

### Added

- 'SMTP safe check' option for cases when the SMTP server does not return an explicit answer that the email does not exist.

```ruby
Truemail.configure do |config|
  config.verifier_email = 'verifier@example.com'
  config.smtp_safe_check = true
end

Truemail.validate('email@example.com')

# Successful SMTP validation
=> #<Truemail::Validator:0x0000000002ca2c70
    @result=
      #<struct Truemail::Validator::Result
        success=true,
        email="email@example.com",
        domain="example.com",
        mail_servers=["mx1.example.com"],
        errors={},
        smtp_debug=
          [#<Truemail::Validate::Smtp::Request:0x0000000002c95d40
            @configuration=
              #<Truemail::Configuration:0x0000000002c95b38
                @connection_timeout=2,
                @email_pattern=/regex_pattern/,
                @response_timeout=2,
                @smtp_safe_check=true,
                @validation_type_by_domain={},
                @verifier_domain="example.com",
                @verifier_email="verifier@example.com">,
              @email="email@example.com",
              @host="mx1.example.com",
              @response=
                #<struct Truemail::Validate::Smtp::Response
                  port_opened=true,
                  connection=false,
                  helo=true,
                  mailfrom=false,
                  rcptto=nil,
                  errors={:mailfrom=>"554 5.7.1 Client host blocked\n", :connection=>"server dropped connection after response"}>>,]>,
    @validation_type=:smtp>
```

### Changed

- `Truemail::VERSION`
- gem documentation
