# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.5.1] - 2021.10.01

### Updated

- Updated gem development dependencies
- Updated gem version

## [2.5.0] - 2021.09.01

### Updated

Optimized DNS (MX) validation flow. Removed needless DNS request for case when custom email pattern was defined and email for validation includes invalid domain name.

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

- `faker` to `ffaker` development dependency

## [2.4.7] - 2021.08.09

### Updated

- Updated gem codebase, refactored `Truemail::ContextHelper`
- Updated tests with `Truemail::DnsHelper#dns_mock_gateway`
- Updated gem development dependencies
- Updated gem version

## [2.4.6] - 2021.07.10

### Fixed

- Wrong domain punycode extraction in DNS validation layer

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

Allowed using special characters in email user names (following [RFC 3696](https://datatracker.ietf.org/doc/html/rfc3696#page-6)) for default regex email pattern.

- Updated `Truemail::RegexConstant::REGEX_EMAIL_PATTERN`, tests
- Updated gem development dependencies
- Updated Rubocop/Codeclimate config
- Updated gem documentation, version

## [2.4.3] - 2021.06.15

### Updated

- Updated gem development dependencies
- Updated Rubocop/Codeclimate config
- Updated gem documentation, version

## [2.4.2] - 2021.05.13

### Fixed

- Fixed security vulnerability for bundler ([CVE-2019-3881](https://github.com/advisories/GHSA-g98m-96g9-wfjq))
- Fixed test coverage issues

### Updated

- Updated gem development dependencies
- Updated simplecov/CircleCi config
- Updated gem documentation, version

## [2.4.1] - 2021.05.05

### Updated

- `Truemail::Validate::MxBlacklist`, tests
- Updated gem development dependencies
- Updated gem documentation, version

## [2.4.0] - 2021.04.28

### Added

- Implemented `MxBlacklist` validation. This layer provides checking mail servers with predefined blacklisted IP addresses list and can be used as a part of DEA ([disposable email address](https://en.wikipedia.org/wiki/Disposable_email_address)) validations.

```ruby
Truemail.configure do |config|
  # Optional parameter. With this option Truemail will filter out unwanted mx servers via
  # predefined list of ip addresses. It can be used as a part of DEA (disposable email
  # address) validations. It is equal to empty array by default.
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

Fixed bug with impossibility to use valid dns port number. Now validation for dns port for range `1..65535` works as expected.

- Updated `Truemail::RegexConstant::REGEX_PORT_NUMBER`, tests
- Updated gem documentation
- CircleCI config moved to `.circleci/config.yml`

## [2.3.3] - 2021.04.14

### Changed

- Updated gem development dependencies
- Updated rubocop/codeclimate config
- Updated CircleCI config

## [2.3.2] - 2021.03.08

### Changed

- Updated gem development dependencies
- Updated rubocop/codeclimate config

## [2.3.1] - 2021.02.26

### Changed

- Updated gem development dependencies
- Updated rubocop/codeclimate config
- Updated tests

## [2.3.0] - 2021.02.05

### Added

- Ability to use custom DNS gateway. Thanks [@le0pard](https://github.com/le0pard) for the great idea and [@verdi8](https://github.com/verdi8) for feature [request](https://github.com/truemail-rb/truemail/issues/126).

```ruby
Truemail.configure do |config|
  # Optional parameter. This option will provide to use custom DNS gateway when Truemail
  # interacts with DNS. If you won't specify nameserver's ports Truemail will use default
  # DNS TCP/UDP port 53. By default Truemail uses DNS gateway from system settings
  # and this option is equal to empty array.
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
- Updated linters/codeclimate configs
- Updated gem runtime/development dependencies
- Updated gem documentation, changelog, version

## [2.2.3] - 2021.01.12

### Fixed

Removed needless `Timeout.timeout` block in `Truemail::Validate::Smtp::Request#check_port`, replaced `TCPSocket` to `Socket` with native timeout detection. Thanks to [@wikiti](https://github.com/wikiti) for idea, testing on production and clean PR [#127](https://github.com/truemail-rb/truemail/pull/127).

### Changed

- Updated `Truemail::Validate::Smtp::Request`
- Updated gem development dependencies
- Updated rubocop, reek configs

## [2.2.2] - 2020.12.30

### Changed

- Updated gem development dependencies
- Updated rubocop config

## [2.2.1] - 2020.12.06

### Fixed

- Filter out ASCII-8BIT chars for serialized SMTP response errors. Fixed `Encoding::UndefinedConversionError` in `Truemail::Log::Serializer::ValidatorJson#serialize`. Thanks to [@eni9889](https://github.com/eni9889) for report
- Added missed `smtp_fail_fast` attribute to serialized validator and auditor results

### Added

- Added `Truemail::Log::Serializer::ValidatorBase#replace_invalid_chars`

### Changed

- Updated `Truemail::Log::Serializer::Base`
- Updated `Truemail::Log::Serializer::ValidatorBase`
- Updated gem development dependencies

## [2.2.0] - 2020.12.01

Ability to use fail fast behaviour for SMTP validation layer. When `smtp_fail_fast = true` it means that `truemail` ends smtp validation session after first attempt on the first mx server in any fail cases (network connection/timeout error, smtp validation error). This feature helps to reduce total time of SMTP validation session up to 1 second.

### Added

- Added `Truemail::Configuration#smtp_fail_fast`
- Added `Truemail::Validate::Smtp#smtp_fail_fast?`
- Added `Truemail::Validate::Smtp#filtered_mail_servers_by_fail_fast_scenario`

### Changed

- Updated `Truemail::Validate::Smtp#attempts`
- Updated `Truemail::Validate::Smtp#establish_smtp_connection`
- Updated gem documentation

It's a configurable and not required option:

```ruby
Truemail.configure do |config|
  config.smtp_fail_fast = true # by default it's equal to false
end
```

Thanks to [@wikiti](https://github.com/wikiti) for timeout reports.

## [2.1.0] - 2020.11.21

Collecting only unique ip-addresses for target mail servers. This update reduces email validation time for case when remote server have closed connection via avoiding connection attempt to server with the same ip address.

### Changed

- Updated `Truemail::Validate::Mx#fetch_target_hosts`

## [2.0.2] - 2020.11.14

### Fixed

Timeouts time units in `Setting global configuration` of Truemail documentation's section. Thanks to [@wikiti](https://github.com/wikiti) for report.

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

SMTP connection errors: invalid `HELO` hostname (`localhost`), duplicate `HELO` (`verifier domain`). Thanks to [@nenoganchev](https://github.com/nenoganchev) for report.

### Changed

- Updated `Truemail::Validate::Smtp::Request#run`
- Updated `Truemail::Validate::Smtp::Request#session_data`
- Updated `Truemail::Validate::Smtp::Response`

Now `helo` is a `Boolean` instead of `Net::SMTP::Response` instance. It was changed because `helo` is sending during SMTP-session initializing (`Net::SMTP.new.start`), and `helo` is always `true` if session up is okay. Also `hello` response won't logged as error if it happens. Example of `Truemail::Validate::Smtp::Response` instance from 2.x version.

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
- error handling for invalid types as input email

### Changed

- Updated `Truemail.validate`
- Updated `Truemail.valid?`

## [1.9.1] - 2020.09.21

### Changed

Migrated to updated Ruby 2.7.x syntax.

- Updated `Truemail::Configuration#logger=`

## [1.9.0] - 2020.09.01

### Added

- Ability to use `Truemail::Auditor` instance represented as json directly
- `Truemail::Log::Serializer::AuditorJson`

### Changed

- `Truemail::Auditor`, `Truemail::Validator`
- serializers namespaces
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
    "dns": "A-record of verifier domain not refers to current host ip address", "ptr": "PTR-record does not reference to current verifier domain"
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

Separated audit features for verifier host.

- `Truemail::Audit::Ip`
- `Truemail::Audit::Dns`

```ruby
Truemail.host_audit

=> #<Truemail::Auditor:0x00005580df358828
@result=
  #<struct Truemail::Auditor::Result
    current_host_ip="127.0.0.1",
    warnings={
      :dns=>"a record of verifier domain not refers to current host ip address",
      :ptr=>"ptr record does not reference to current verifier domain"
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

- Ability to show `not_rfc_mx_lookup_flow` attribute in serialized validation result

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

- Ability to use not RFC MX lookup flow (MX and Null MX records will be checked on the DNS validation layer only)

```ruby
Truemail.configure do |config|
  # Optional parameter. This option will provide to use not RFC MX lookup flow.
  # It means that MX and Null MX records will be cheked on the DNS validation layer only.
  # By default this option is disabled.
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

`Truemail::Configuration.retry_count` deprecated, and alias for this method has been removed. Please use `Truemail::Configuration.connection_attempts` instead.

## [1.6.0] - 2020-02-01

### Added

- Ability to use `Truemail::Validator` instance represented as json directly

### Changed

- gem development dependencies
- gem documentation

## [1.5.1] - 2020-01-20

### Changed

- gem development dependencies
- gem documentation

## [1.5.0] - 2019-12-29

### Added

- Supporting of internationalized emails ([EAI](https://en.wikipedia.org/wiki/International_email)). Now you can validate emails, like: `dörte@sörensen.de`, `квіточка@пошта.укр`, `alegría@mañana.es`

### Changed

- `Truemail::RegexConstant::REGEX_DOMAIN`
- `Truemail::RegexConstant::REGEX_EMAIL_PATTERN`
- `Truemail::Validator::Result`
- `Truemail::Validate::Mx#run`
- `Truemail::Validate::Smtp#establish_smtp_connection`
- gem runtime dependencies
- gem development dependencies
- gem documentation
- linters configs

## [1.4.2] - 2019-11-27

### Changed

- `Truemail::Configuration`
- gem development dependencies
- linters configs

## [1.4.1] - 2019-11-20

### Changed

- gem development dependencies
- gem documentation
- linters configs

### Removed

- truemail rspec helpers (moved to independent gem [`truemail-rspec`](https://github.com/truemail-rb/truemail-rspec))

## [1.4.0] - 2019-10-28

### Added

- Event logger (ability to output validation logs to stdout/file)
- JSON serializer for validator instance
- [Changelog](CHANGELOG.md)
- [Logo](https://repository-images.githubusercontent.com/173723932/6dffee00-e88e-11e9-94b6-c97aacc0df00)

Truemail gem allows to output tracking events to stdout/file or both of these. Please note, at least one of the outputs must exist. Tracking event by default is `:error`

**Available tracking events**

- `:all`, all detected events including success validation cases
- `:unrecognized_error`, unrecognized errors only (when `smtp_safe_check = true` and SMTP server does not return an exact answer that the email does not exist)
- `:recognized_error`, recognized errors only
- `:error`, recognized and unrecognized errors only

```ruby
Truemail.configure do |config|
  config.logger = { tracking_event: :all, stdout: true, log_absolute_path: '/home/app/log/truemail.log' }
end
```

Also starting from this version Truemail has built in JSON serializer for `Truemail::Validator` instance, so you can represent your email validation result as json.

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

- Ability to create new `Truemail::Configuration` instance with block
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

When email domain in whitelist and ```whitelist_validation``` is sets equal to ```true``` validation type will be passed to other validators. Validation of email which not contains whitelisted domain always will return ```false```.

```ruby
Truemail.configure do |config|
  config.verifier_email = 'verifier@example.com'
  config.whitelisted_domains = ['white-domain.com']
  config.whitelist_validation = true
end
```

**Email has whitelisted domain**

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

**Email hasn't whitelisted domain**

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

You can predefine default validation type for `Truemail.validate('email@email.com')` call without with-parameter. Available validation types: `:regex`, `:mx`, `:smtp`. By default validation type still remains `:smtp`

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

- Feature domain whitelist blacklist. Other validations will not processed even if it was defined in `validation_type_for`.

```ruby
Truemail.configure do |config|
  # Optional parameter. Validation of email which contains whitelisted domain
  # always will return true.
  config.whitelisted_domains = ['somedomain1.com', 'somedomain2.com']

  # Optional parameter. Validation of email which contains whitelisted domain
  # always will return false.
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

- error key in `lower_snake_case`

### Changed

- `Truemail::VERSION`
- gem documentation

## [0.2] - 2019-05-23

### Added

- skip validation by domain for `validation_type_for` configuration option:

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

- Empty ptr constant

## [0.1.8] - 2019-04-29

### Added

- Reverse trace, [issue details](https://github.com/truemail-rb/truemail/issues/18)

### Fixed

- Behaviour of current host address resolver, [issue details](https://github.com/truemail-rb/truemail/issues/18)

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

- MX gem logic with [RFC 7505](https://tools.ietf.org/html/rfc7505), null MX record supporting, [issue details](https://github.com/truemail-rb/truemail/issues/27)
- [Contributing guideline](CONTRIBUTING.md)

### Fixed

- Multihomed MX records supporting, [issue details](https://github.com/truemail-rb/truemail/issues/28)

### Changed

- `Truemail::VERSION`
- gem documentation

## [0.1.5] - 2019-04-05

### Added

- Retries for `Truemail::Validate::Smtp` for cases when one mx server

### Changed

- `Truemail::Configuration` class, please use `.connection_attempts` instead `.retry_count`
- `Truemail::VERSION`
- gem documentation

## [0.1.4] - 2019-04-01

### Added

- Checking A record presence if `MX` and `CNAME` records not exist, [issue details](https://github.com/truemail-rb/truemail/issues/10)
- Handling of `CNAME` records, [issue details](https://github.com/truemail-rb/truemail/issues/11)
- Checking A record if `MX` and `CNAME` records not found, [issue details](https://github.com/truemail-rb/truemail/issues/12)
- Supporting of multihomed MX records, conversion host names to ips, [issue details](https://github.com/truemail-rb/truemail/issues/17)
- Timeout configuration for DNS resolver, [issue details](https://github.com/truemail-rb/truemail/issues/13)
- `.valid?` helper

### Changed

- `Truemail::VERSION`
- gem documentation

## [0.1.3] - 2019-03-27

### Added

- Independent domain name extractor to `Truemail::Validate::Mx#run`

### Fixed

- Default `REGEX_EMAIL_PATTERN`, [issue details](https://github.com/truemail-rb/truemail/issues/7)
  * local part of address can't start with a dot or special symbol
  * local part of address can include ```+``` symbol
- Default `REGEX_DOMAIN_PATTERN`, [issue details](https://github.com/truemail-rb/truemail/issues/8)
  * TLD size increased up to 63 characters
- Case sensitive domain names, [issue details](https://github.com/truemail-rb/truemail/issues/9)

### Changed

- `Truemail::VERSION`
- gem documentation

## [0.1.0] - 2019-03-26

### Added

- 'SMTP safe check' option for cases when SMTP server does not return an exact answer that the email does not exist.

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
