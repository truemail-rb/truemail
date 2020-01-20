# Changelog
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- Configurable default validation type, [issue details](https://github.com/rubygarage/truemail/issues/48)

You can predefine default validation type for ```Truemail.validate('email@email.com')``` call without with-parameter. Available validation types: ```:regex```, ```:mx```, ```:smtp```. By default validation type still remains ```:smtp```

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
- Feature domain whitelist blacklist. Other validations will not processed even if it was defined in ```validation_type_for```.

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
- ```:skip``` validation type for ```validation_type_for```

### Fixed
- error key in `lower_snake_case`

### Changed
- `Truemail::VERSION`
- gem documentation

## [0.2] - 2019-05-23
### Added
- skip validation by domain for validation_type_for configuration option:

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
- SMTP error body configurable option, [issue details](https://github.com/rubygarage/truemail/issues/19)

### Changed
- `Truemail::VERSION`
- gem documentation

## [0.1.9] - 2019-04-29
### Fixed
- Empty ptr constant

## [0.1.8] - 2019-04-29
### Added
- Reverse trace, [issue details](https://github.com/rubygarage/truemail/issues/18)

### Fixed
- Behaviour of current host address resolver, [issue details](https://github.com/rubygarage/truemail/issues/18)

### Changed
- `Truemail::VERSION`
- gem documentation

## [0.1.7] - 2019-04-17
### Added
- PTR record audit, [issue details](https://github.com/rubygarage/truemail/issues/18)

### Changed
- `Truemail::VERSION`
- gem documentation

## [0.1.6] - 2019-04-08
### Added
- MX gem logic with [RFC 7505](https://tools.ietf.org/html/rfc7505), null MX record supporting, [issue details](https://github.com/rubygarage/truemail/issues/27)
- [Contributing guideline](CONTRIBUTING.md)

### Fixed
- Multihomed MX records supporting, [issue details](https://github.com/rubygarage/truemail/issues/28)

### Changed
- `Truemail::VERSION`
- gem documentation

## [0.1.5] - 2019-04-05
### Added
- Retries for ```Truemail::Validate::Smtp``` for cases when one mx server

### Changed
- ```Truemail::Configuration``` class, please use ```.connection_attempts``` instead ```.retry_count```
- `Truemail::VERSION`
- gem documentation

## [0.1.4] - 2019-04-01
### Added
- Checking A record presence if ```MX``` and ```CNAME``` records not exist, [issue details](https://github.com/rubygarage/truemail/issues/10)
- Handling of ```CNAME``` records, [issue details](https://github.com/rubygarage/truemail/issues/11)
- Checking A record if ```MX``` and ```CNAME``` records not found, [issue details](https://github.com/rubygarage/truemail/issues/12)
- Supporting of multihomed MX records, conversion host names to ips, [issue details](https://github.com/rubygarage/truemail/issues/17)
- Timeout configuration for DNS resolver, [issue details](https://github.com/rubygarage/truemail/issues/13)
- ```.valid?``` helper

### Changed
- `Truemail::VERSION`
- gem documentation

## [0.1.3] - 2019-03-27
### Added
- Independent domain name extractor to ```Truemail::Validate::Mx#run```

### Fixed
- Default ```REGEX_EMAIL_PATTERN```, [issue details](https://github.com/rubygarage/truemail/issues/7)
  * local part of address can't start with a dot or special symbol
  * local part of address can include ```+``` symbol
- Default ```REGEX_DOMAIN_PATTERN```, [issue details](https://github.com/rubygarage/truemail/issues/8)
  * TLD size increased up to 63 characters
- Case sensitive domain names, [issue details](https://github.com/rubygarage/truemail/issues/9)

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
                  helo=
                    #<Net::SMTP::Response:0x0000000002c934c8
                    @status="250",
                    @string="250 mx1.example.com\n">,
                  mailfrom=false,
                  rcptto=nil,
                  errors={:mailfrom=>"554 5.7.1 Client host blocked\n", :connection=>"server dropped connection after response"}>>,]>,
    @validation_type=:smtp>
```

### Changed
- `Truemail::VERSION`
- gem documentation
