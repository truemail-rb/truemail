# ![Truemail - configurable, framework-agnostic plain Ruby email validator](https://truemail-rb.org/assets/images/truemail_logo.png)

[![Codecov](https://codecov.io/gh/truemail-rb/truemail/branch/master/graph/badge.svg)](https://codecov.io/gh/truemail-rb/truemail)
[![CircleCI](https://circleci.com/gh/truemail-rb/truemail/tree/master.svg?style=svg)](https://circleci.com/gh/truemail-rb/truemail/tree/master)
[![Gem Version](https://badge.fury.io/rb/truemail.svg)](https://badge.fury.io/rb/truemail)
[![Downloads](https://img.shields.io/gem/dt/truemail.svg?colorA=004d99&colorB=0073e6)](https://rubygems.org/gems/truemail)
[![In Awesome Ruby](https://raw.githubusercontent.com/sindresorhus/awesome/main/media/mentioned-badge.svg)](https://github.com/markets/awesome-ruby)
[![Gitter](https://badges.gitter.im/truemail-rb/community.svg)](https://gitter.im/truemail-rb/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![GitHub](https://img.shields.io/github/license/truemail-rb/truemail)](LICENSE.txt)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v1.4%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md)

Configurable, framework-agnostic plain Ruby email validator. Verify emails via regex, DNS, SMTP and more. Be sure that an email address is valid and actually exists.

> The current, maintained developer documentation :books: lives [here](https://truemail-rb.org/truemail-gem).

## Table of Contents

- [Synopsis](#synopsis)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Configuration features](#configuration-features)
    - [Setting global configuration](#setting-global-configuration)
      - [Read global configuration](#read-global-configuration)
      - [Update global configuration](#update-global-configuration)
      - [Reset global configuration](#reset-global-configuration)
    - [Using custom independent configuration](#using-custom-independent-configuration)
  - [Validation features](#validation-features)
    - [Whitelist/Blacklist check](#whitelistblacklist-check)
      - [Whitelist case](#whitelist-case)
      - [Whitelist validation case](#whitelist-validation-case)
      - [Blacklist case](#blacklist-case)
      - [Duplication case](#duplication-case)
    - [Regex validation](#regex-validation)
      - [With default regex pattern](#with-default-regex-pattern)
      - [With custom regex pattern](#with-custom-regex-pattern)
    - [DNS (MX) validation](#mx-validation)
      - [RFC MX lookup flow](#rfc-mx-lookup-flow)
      - [Non-RFC MX lookup flow](#non-rfc-mx-lookup-flow)
    - [MX blacklist validation](#mx-blacklist-validation)
    - [SMTP validation](#smtp-validation)
      - [SMTP fail fast enabled](#smtp-fail-fast-enabled)
      - [SMTP safe check disabled](#smtp-safe-check-disabled)
      - [SMTP safe check enabled](#smtp-safe-check-enabled)
  - [Host audit features](#host-audit-features)
    - [IP audit](#ip-audit)
    - [DNS audit](#dns-audit)
    - [PTR audit](#ptr-audit)
    - [Usage example](#usage-example)
  - [Event logger](#event-logger)
    - [Using custom logger](#using-custom-logger)
    - [Available tracking events](#available-tracking-events)
  - [JSON serializers](#json-serializers)
    - [Auditor JSON serializer](#auditor-json-serializer)
    - [Validator JSON serializer](#validator-json-serializer)
  - [Truemail helpers](#truemail-helpers)
    - [.valid?](#valid)
    - [#as_json](#as_json)
  - [Test environment](#test-environment)
- [Truemail family](#truemail-family)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)
- [Credits](#credits)
- [Versioning](#versioning)
- [Changelog](CHANGELOG.md)

## Synopsis

Email validation is a tricky thing. There are a number of different ways to validate an email address, and all of them must follow best practices and provide proper validation. The Truemail gem helps you validate emails via a regex pattern, the presence of DNS records, and the real existence of the email account on the target mail server.

**Syntax check**: checks the email address against a regex pattern.

**Mail server existence check**: checks that the email address domain has mail servers, using DNS records.

**Mailbox existence check**: checks whether the email address really exists and can receive email, using SMTP connections and email-sending emulation.

Truemail can also audit the host it runs on.

## Features

- Configurable validator, validate only what you need
- Support for internationalized emails ([EAI](https://en.wikipedia.org/wiki/Email_address#Internationalization))
- Whitelist/blacklist validation layers
- Ability to configure different MX/SMTP validation flows
- Ability to configure a [DEA](https://en.wikipedia.org/wiki/Disposable_email_address) validation flow
- Simple SMTP debugger
- Event logger
- Host auditor tools (help detect common host problems that interfere with proper email verification)
- JSON serializers
- Ability to use the library as an independent, stateless microservice ([Truemail Server](https://truemail-rb.org/truemail-rack))

## Requirements

Ruby MRI 2.5.0+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'truemail'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install truemail
```

## Usage

### Configuration features

You can use a global gem configuration or a custom, independent configuration. Available configuration options:

- verifier email
- verifier domain
- email pattern
- SMTP error body pattern
- connection timeout
- response timeout
- connection attempts
- default validation type
- validation type for domains
- whitelisted emails
- blacklisted emails
- whitelisted domains
- blacklisted domains
- whitelist validation
- blacklisted MX IP addresses
- custom DNS gateway(s)
- RFC MX lookup flow
- SMTP port number
- SMTP fail fast
- SMTP safe check
- event logger
- JSON serializer

#### Setting global configuration

To get access to `Truemail.configuration` and the gem's configuration features, you must configure it first, as in the example below:

```ruby
require 'truemail'

Truemail.configure do |config|
  # Required parameter. Must be an existing email address on whose behalf verification will be performed
  config.verifier_email = 'verifier@example.com'

  # Optional parameter. Must be an existing domain on whose behalf verification will be performed.
  # By default the verifier domain is derived from the verifier email
  config.verifier_domain = 'somedomain.com'

  # Optional parameter. You can override the default regex pattern
  config.email_pattern = /regex_pattern/

  # Optional parameter. You can override the default regex pattern
  config.smtp_error_body_pattern = /regex_pattern/

  # Optional parameter. Connection timeout in seconds.
  # It defaults to 2.
  config.connection_timeout = 1

  # Optional parameter. SMTP server response timeout in seconds.
  # It defaults to 2.
  config.response_timeout = 1

  # Optional parameter. Total number of connection attempts. It defaults to 2.
  # This parameter is used on MX lookup timeout errors and for SMTP requests (when
  # there is only one MX server).
  config.connection_attempts = 3

  # Optional parameter. You can predefine the default validation type for
  # Truemail.validate('email@email.com') calls made without the with: parameter.
  # Available validation types: :regex, :mx, :mx_blacklist, :smtp
  config.default_validation_type = :mx

  # Optional parameter. You can predefine which validation type will be used for specific domains.
  # You can also skip validation for a domain.
  # Available validation types: :regex, :mx, :mx_blacklist, :smtp
  # This setting takes precedence over the current or default validation type.
  # All validations for 'somedomain.com' will be performed with regex validation only,
  # and all validations for 'otherdomain.com' with MX validation only.
  # It defaults to an empty hash.
  config.validation_type_for = { 'somedomain.com' => :regex, 'otherdomain.com' => :mx }

  # Optional parameter. Validation of a whitelisted email will always return true.
  # Other validations will not be performed, even if defined in validation_type_for.
  # It defaults to an empty array.
  config.whitelisted_emails = %w[user@somedomain1.com user@somedomain2.com]

  # Optional parameter. Validation of a blacklisted email will always return false.
  # Other validations will not be performed, even if defined in validation_type_for.
  # It defaults to an empty array.
  config.blacklisted_emails = %w[user@somedomain3.com user@somedomain4.com]

  # Optional parameter. Validation of an email with a whitelisted domain will always return true.
  # Other validations will not be performed, even if defined in validation_type_for.
  # It defaults to an empty array.
  config.whitelisted_domains = %w[somedomain1.com somedomain2.com]

  # Optional parameter. Validation of an email with a blacklisted domain will always return false.
  # Other validations will not be performed, even if defined in validation_type_for.
  # It defaults to an empty array.
  config.blacklisted_domains = %w[somedomain3.com somedomain4.com]

  # Optional parameter. With this option Truemail will only validate emails with a whitelisted
  # domain, i.e. if the domain is whitelisted, validation is passed on to the regex, MX or SMTP
  # validators. Validation of an email whose domain is not whitelisted will always return false.
  # It defaults to false.
  config.whitelist_validation = true

  # Optional parameter. With this option Truemail will filter out unwanted MX servers using
  # a predefined list of IP addresses. It can be used as part of DEA (disposable email
  # address) validation. It defaults to an empty array.
  config.blacklisted_mx_ip_addresses = %w[1.1.1.1 2.2.2.2]

  # Optional parameter. This option makes Truemail use custom DNS gateways when it
  # interacts with DNS. Valid port numbers are in the range 1-65535. If you don't specify
  # a nameserver port, Truemail will use the default DNS TCP/UDP port 53. By default Truemail
  # uses the DNS gateway from the system settings, and this option is an empty array.
  config.dns = %w[10.0.0.1 10.0.0.2:54]

  # Optional parameter. This option enables the non-RFC MX lookup flow.
  # It means that only MX and Null MX records will be checked on the DNS validation layer.
  # This option is disabled by default.
  config.not_rfc_mx_lookup_flow = true

  # Optional parameter. SMTP port number. It defaults to 25.
  config.smtp_port = 2525

  # Optional parameter. This option enables SMTP fail-fast behavior. When
  # smtp_fail_fast = true, Truemail ends the SMTP validation session after the first
  # attempt on the first MX server in any failure case (network connection/timeout error,
  # SMTP validation error). This feature helps reduce the total time of an SMTP validation
  # session to about 1 second. This option is disabled by default.
  config.smtp_fail_fast = true

  # Optional parameter. This option makes Truemail parse the bodies of SMTP errors. It is helpful
  # when the SMTP server does not return an explicit answer that the email does not exist.
  # This option is disabled by default and applies to SMTP validation only.
  config.smtp_safe_check = true

  # Optional parameter. This option enables event tracking. You can print tracking
  # events to stdout, write them to a file, or both. The default logger instance is the Logger
  # from the Ruby stdlib. You can override this behavior; see the examples below.
  # The default tracking event is :error.
  # Available tracking events: :all, :unrecognized_error, :recognized_error, :error
  config.logger = {
    tracking_event: :all,
    stdout: true,
    log_absolute_path: '/home/app/log/truemail.log'
  }
end
```

##### Read global configuration

After successful configuration, you can read the current Truemail configuration instance anywhere in your application.

```ruby
Truemail.configuration

=> #<Truemail::Configuration:0x000055590cb17b40
 @connection_timeout=1,
 @email_pattern=/regex_pattern/,
 @smtp_error_body_pattern=/regex_pattern/,
 @response_timeout=1,
 @connection_attempts=3,
 @default_validation_type=:mx,
 @validation_type_by_domain={"somedomain.com" => :regex, "otherdomain.com" => :mx},
 @whitelisted_emails=["user@somedomain1.com", "user@somedomain2.com"],
 @blacklisted_emails=["user@somedomain3.com", "user@somedomain4.com"],
 @whitelisted_domains=["somedomain1.com", "somedomain2.com"],
 @blacklisted_domains=["somedomain3.com", "somedomain4.com"],
 @whitelist_validation=true,
 @blacklisted_mx_ip_addresses=["1.1.1.1", "2.2.2.2"],
 @dns=["10.0.0.1", "10.0.0.2:54"],
 @verifier_domain="somedomain.com",
 @verifier_email="verifier@example.com",
 @not_rfc_mx_lookup_flow=true,
 @smtp_port=2525,
 @smtp_fail_fast=true,
 @smtp_safe_check=true,
 @logger=#<Truemail::Logger:0x0000557f837450b0
   @event=:all, @file="/home/app/log/truemail.log", @custom_logger=nil @stdout=true>>
```

##### Update global configuration

```ruby
Truemail.configuration.connection_timeout = 3
=> 3
Truemail.configuration.response_timeout = 4
=> 4
Truemail.configuration.connection_attempts = 1
=> 1

Truemail.configuration
=> #<Truemail::Configuration:0x000055590cb17b40
 @connection_timeout=3,
 @email_pattern=/regex_pattern/,
 @smtp_error_body_pattern=/regex_pattern/,
 @response_timeout=4,
 @connection_attempts=1,
 @default_validation_type=:mx,
 @validation_type_by_domain={"somedomain.com" => :regex, "otherdomain.com" => :mx},
 @whitelisted_emails=["user@somedomain1.com", "user@somedomain2.com"],
 @blacklisted_emails=["user@somedomain3.com", "user@somedomain4.com"],
 @whitelisted_domains=["somedomain1.com", "somedomain2.com"],
 @blacklisted_domains=["somedomain3.com", "somedomain4.com"],
 @whitelist_validation=true,
 @blacklisted_mx_ip_addresses=["1.1.1.1", "2.2.2.2"],
 @dns=["10.0.0.1", "10.0.0.2:54"],
 @verifier_domain="somedomain.com",
 @verifier_email="verifier@example.com",
 @not_rfc_mx_lookup_flow=true,
 @smtp_port=2525,
 @smtp_fail_fast=true,
 @smtp_safe_check=true,
 @logger=#<Truemail::Logger:0x0000557f837450b0
   @event=:all, @file="/home/app/log/truemail.log", @custom_logger=nil @stdout=true>>
```

##### Reset global configuration

You can also reset the Truemail configuration.

```ruby
Truemail.reset_configuration!
=> nil
Truemail.configuration
=> nil
```

#### Using custom independent configuration

Allows you to use an independent configuration for each validation/audit instance. When using this feature you do not need a global Truemail configuration.

```ruby
custom_configuration = Truemail::Configuration.new do |config|
  config.verifier_email = 'verifier@example.com'
end

Truemail.validate('email@example.com', custom_configuration: custom_configuration)
Truemail.valid?('email@example.com', custom_configuration: custom_configuration)
Truemail.host_audit('email@example.com', custom_configuration: custom_configuration)
```

Please note that you need either a global or a custom configuration to use the Truemail gem.

### Validation features

#### Whitelist/Blacklist check

The whitelist/blacklist check is validation level zero. You can define lists of whitelisted and blacklisted emails/domains. Validation of a whitelisted email or domain will always return `true`, and validation of a blacklisted email or domain will always return `false`.

Please note that other validations will not be performed, even if defined in `validation_type_for`.

**Sequence of list checks:**

1. Whitelist check
2. Whitelist validation check
3. Blacklist check

Example of usage:

```ruby
require 'truemail'

Truemail.configure do |config|
  config.verifier_email = 'verifier@example.com'
  config.whitelisted_emails = %w[user@somedomain1.com user@somedomain2.com]
  config.blacklisted_emails = %w[user@somedomain3.com user@somedomain4.com]
  config.whitelisted_domains = %w[white-domain.com somedomain.com]
  config.blacklisted_domains = %w[black-domain.com somedomain.com]
  config.validation_type_for = { 'somedomain.com' => :mx }
end
```

##### Whitelist case

When the email is whitelisted, the validation type is redefined. The validation result is `true`.

```ruby
Truemail.validate('email@white-domain.com')

#<Truemail::Validator:0x000055b8429f3490
  @result=#<struct Truemail::Validator::Result
    success=true,
    email="email@white-domain.com",
    domain="white-domain.com",
    mail_servers=[],
    errors={},
    smtp_debug=nil>,
    configuration=#<Truemail::Configuration:0x00005629f801bd28
     @whitelisted_emails=["user@somedomain1.com", "user@somedomain2.com"],
     @blacklisted_emails=["user@somedomain3.com", "user@somedomain4.com"],
     @blacklisted_domains=["black-domain.com", "somedomain.com"],
     @blacklisted_mx_ip_addresses=[],
     @dns=[],
     @connection_attempts=2,
     @connection_timeout=2,
     @default_validation_type=:smtp,
     @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
     @response_timeout=2,
     @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
     @not_rfc_mx_lookup_flow=false,
     @smtp_port=25,
     @smtp_fail_fast=false,
     @smtp_safe_check=false,
     @validation_type_by_domain={"somedomain.com"=>:mx},
     @verifier_domain="example.com",
     @verifier_email="verifier@example.com",
     @whitelist_validation=false,
     @whitelisted_domains=["white-domain.com", "somedomain.com"]>,
  @validation_type=:whitelist>
```

##### Whitelist validation case

```ruby
require 'truemail'

Truemail.configure do |config|
  config.verifier_email = 'verifier@example.com'
  config.whitelisted_domains = %w[white-domain.com]
  config.whitelist_validation = true
end
```

When the email domain is whitelisted and `whitelist_validation` is set to `true`, validation is passed on to the other validators. Validation of an email whose domain is not whitelisted will always return `false`.

###### Email has a whitelisted domain

```ruby
Truemail.validate('email@white-domain.com', with: :regex)

#<Truemail::Validator:0x000055b8429f3490
  @result=#<struct Truemail::Validator::Result
    success=true,
    email="email@white-domain.com",
    domain="white-domain.com",
    mail_servers=[],
    errors={},
    smtp_debug=nil>,
    configuration=
    #<Truemail::Configuration:0x0000563f0d2605c8
     @whitelisted_emails=[],
     @blacklisted_emails=[],
     @blacklisted_domains=[],
     @blacklisted_mx_ip_addresses=[],
     @dns=[],
     @connection_attempts=2,
     @connection_timeout=2,
     @default_validation_type=:smtp,
     @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
     @response_timeout=2,
     @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
     @not_rfc_mx_lookup_flow=false,
     @smtp_port=25,
     @smtp_fail_fast=false,
     @smtp_safe_check=false,
     @validation_type_by_domain={},
     @verifier_domain="example.com",
     @verifier_email="verifier@example.com",
     @whitelist_validation=true,
     @whitelisted_domains=["white-domain.com"]>,
  @validation_type=:regex>
```

###### Email does not have a whitelisted domain

```ruby
Truemail.validate('email@domain.com', with: :regex)

#<Truemail::Validator:0x000055b8429f3490
  @result=#<struct Truemail::Validator::Result
    success=false,
    email="email@domain.com",
    domain="domain.com",
    mail_servers=[],
    errors={},
    smtp_debug=nil>,
    configuration=
    #<Truemail::Configuration:0x0000563f0cd82ab0
     @whitelisted_emails=[],
     @blacklisted_emails=[],
     @blacklisted_domains=[],
     @blacklisted_mx_ip_addresses=[],
     @dns=[],
     @connection_attempts=2,
     @connection_timeout=2,
     @default_validation_type=:smtp,
     @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
     @response_timeout=2,
     @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
     @not_rfc_mx_lookup_flow=false,
     @smtp_port=25,
     @smtp_fail_fast=false,
     @smtp_safe_check=false,
     @validation_type_by_domain={},
     @verifier_domain="example.com",
     @verifier_email="verifier@example.com",
     @whitelist_validation=true,
     @whitelisted_domains=["white-domain.com"]>,
  @validation_type=:blacklist>
```

##### Blacklist case

When the email is blacklisted, the validation type is redefined too. The validation result is `false`.

```ruby
Truemail.validate('email@black-domain.com')

#<Truemail::Validator:0x000023y8429f3493
  @result=#<struct Truemail::Validator::Result
    success=false,
    email="email@black-domain.com",
    domain="black-domain.com",
    mail_servers=[],
    errors={},
    smtp_debug=nil>,
    configuration=
    #<Truemail::Configuration:0x0000563f0d36f4f0
     @whitelisted_emails=[],
     @blacklisted_emails=[],
     @blacklisted_domains=[],
     @blacklisted_mx_ip_addresses=[],
     @dns=[],
     @connection_attempts=2,
     @connection_timeout=2,
     @default_validation_type=:smtp,
     @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
     @response_timeout=2,
     @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
     @not_rfc_mx_lookup_flow=false,
     @smtp_port=25,
     @smtp_fail_fast=false,
     @smtp_safe_check=false,
     @validation_type_by_domain={},
     @verifier_domain="example.com",
     @verifier_email="verifier@example.com",
     @whitelist_validation=true,
     @whitelisted_domains=["white-domain.com"]>,
  @validation_type=:blacklist>
```

##### Duplication case

The validation result for this email is `true`, because it was found in the whitelisted domains list first. The `validation_type` is redefined in this case as well.

```ruby
Truemail.validate('email@somedomain.com')

#<Truemail::Validator:0x000055b8429f3490
  @result=#<struct Truemail::Validator::Result
    success=true,
    email="email@somedomain.com",
    domain="somedomain.com",
    mail_servers=[],
    errors={},
    smtp_debug=nil>,
    configuration=
    #<Truemail::Configuration:0x0000563f0d3f8fc0
     @whitelisted_emails=[],
     @blacklisted_emails=[],
     @blacklisted_domains=[],
     @blacklisted_mx_ip_addresses=[],
     @dns=[],
     @connection_attempts=2,
     @connection_timeout=2,
     @default_validation_type=:smtp,
     @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
     @response_timeout=2,
     @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
     @not_rfc_mx_lookup_flow=false,
     @smtp_port=25,
     @smtp_fail_fast=false,
     @smtp_safe_check=false,
     @validation_type_by_domain={},
     @verifier_domain="example.com",
     @verifier_email="verifier@example.com",
     @whitelist_validation=true,
     @whitelisted_domains=["white-domain.com"]>,
  @validation_type=:whitelist>
```

#### Regex validation

Validation with a regex pattern is the first validation level. It runs the whitelist/blacklist check before running itself.

```code
[Whitelist/Blacklist] -> [Regex validation]
```

By default this validation does not strictly follow the [RFC 5322](https://www.ietf.org/rfc/rfc5322.txt) standard, so you can override Truemail's default regex pattern if you want.

Example of usage:

##### With default regex pattern

```ruby
require 'truemail'

Truemail.configure do |config|
  config.verifier_email = 'verifier@example.com'
end

Truemail.validate('email@example.com', with: :regex)

=> #<Truemail::Validator:0x000055590cc9bdb8
  @result=
    #<struct Truemail::Validator::Result
      success=true,
      email="email@example.com",
      domain="example.com",
      mail_servers=[],
      errors={},
      smtp_debug=nil>,
      configuration=
      #<Truemail::Configuration:0x000055aa56a54d48
       @whitelisted_emails=[],
       @blacklisted_emails=[],
       @blacklisted_domains=[],
       @blacklisted_mx_ip_addresses=[],
       @dns=[],
       @connection_attempts=2,
       @connection_timeout=2,
       @default_validation_type=:smtp,
       @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
       @response_timeout=2,
       @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
       @not_rfc_mx_lookup_flow=false,
       @smtp_port=25,
       @smtp_fail_fast=false,
       @smtp_safe_check=false,
       @validation_type_by_domain={},
       @verifier_domain="example.com",
       @verifier_email="verifier@example.com",
       @whitelist_validation=false,
       @whitelisted_domains=[]>,
  @validation_type=:regex>
```

##### With custom regex pattern

You should define your custom regex pattern in the gem configuration first.

```ruby
require 'truemail'

Truemail.configure do |config|
  config.verifier_email = 'verifier@example.com'
  config.email_pattern = /regex_pattern/
end

Truemail.validate('email@example.com', with: :regex)

=> #<Truemail::Validator:0x000055590ca8b3e8
  @result=
    #<struct Truemail::Validator::Result
      success=true,
      email="email@example.com",
      domain="example.com",
      mail_servers=[],
      errors={},
      smtp_debug=nil>,
      configuration=
      #<Truemail::Configuration:0x0000560e58d80830
       @whitelisted_emails=[],
       @blacklisted_emails=[],
       @blacklisted_domains=[],
       @blacklisted_mx_ip_addresses=[],
       @dns=[],
       @connection_attempts=2,
       @connection_timeout=2,
       @default_validation_type=:smtp,
       @email_pattern=/regex_pattern/,
       @response_timeout=2,
       @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
       @not_rfc_mx_lookup_flow=false,
       @smtp_port=25,
       @smtp_fail_fast=false,
       @smtp_safe_check=false,
       @validation_type_by_domain={},
       @verifier_domain="example.com",
       @verifier_email="verifier@example.com",
       @whitelist_validation=false,
       @whitelisted_domains=[]>,
  @validation_type=:regex>
```

#### MX validation

This is in fact DNS validation, because it checks more than just MX records. DNS validation is the second validation level, historically named MX validation. It runs regex validation first, and only runs itself once regex validation has completed successfully.

```code
[Whitelist/Blacklist] -> [Regex validation] -> [MX validation]
```

Please note that the Truemail MX validator [does not enforce](https://github.com/truemail-rb/truemail/issues/26) strict compliance with the [RFC 5321](https://tools.ietf.org/html/rfc5321#section-5) standard, for the best validation outcome.

##### RFC MX lookup flow

[Truemail MX lookup](https://slides.com/vladislavtrotsenko/truemail#/0/9) is based on RFC 5321. It consists of 3 sub-steps: the MX, CNAME and A record resolvers. Each resolver attempts to extract the mail servers from the email domain. If at least one server exists, validation is successful. Iteration continues until a resolver returns true.

Example of usage:

```ruby
require 'truemail'

Truemail.configure do |config|
  config.verifier_email = 'verifier@example.com'
end

Truemail.validate('email@example.com', with: :mx)

=> #<Truemail::Validator:0x000055590c9c1c50
  @result=
    #<struct Truemail::Validator::Result
      success=true,
      email="email@example.com",
      domain="example.com",
      mail_servers=["127.0.1.1", "127.0.1.2"],
      errors={},
      smtp_debug=nil>,
      configuration=
      #<Truemail::Configuration:0x0000559b6e44af70
       @whitelisted_emails=[],
       @blacklisted_emails=[],
       @blacklisted_domains=[],
       @blacklisted_mx_ip_addresses=[],
       @dns=[],
       @connection_attempts=2,
       @connection_timeout=2,
       @default_validation_type=:smtp,
       @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
       @response_timeout=2,
       @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
       @not_rfc_mx_lookup_flow=false,
       @smtp_port=25,
       @smtp_fail_fast=false,
       @smtp_safe_check=false,
       @validation_type_by_domain={},
       @verifier_domain="example.com",
       @verifier_email="verifier@example.com",
       @whitelist_validation=false,
       @whitelisted_domains=[]>,
  @validation_type=:mx>
```

##### Non-RFC MX lookup flow

Truemail can also use a non-RFC MX lookup flow. It runs the MX resolver only, skipping the CNAME and A record fallbacks that RFC 5321 prescribes, so a domain without MX records is treated as having no mail servers. This option is disabled by default.

Example of usage:

```ruby
require 'truemail'

Truemail.configure do |config|
  config.verifier_email = 'verifier@example.com'
  config.not_rfc_mx_lookup_flow = true
end

Truemail.validate('email@example.com', with: :mx)

=> #<Truemail::Validator:0x000055590c9c1c50
  @result=
    #<struct Truemail::Validator::Result
      success=true,
      email="email@example.com",
      domain="example.com",
      mail_servers=["127.0.1.1", "127.0.1.2"],
      errors={},
      smtp_debug=nil>,
      configuration=
      #<Truemail::Configuration:0x0000559b6e44af70
       @whitelisted_emails=[],
       @blacklisted_emails=[],
       @blacklisted_domains=[],
       @blacklisted_mx_ip_addresses=[],
       @dns=[],
       @connection_attempts=2,
       @connection_timeout=2,
       @default_validation_type=:smtp,
       @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
       @response_timeout=2,
       @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
       @not_rfc_mx_lookup_flow=true,
       @smtp_port=25,
       @smtp_fail_fast=false,
       @smtp_safe_check=false,
       @validation_type_by_domain={},
       @verifier_domain="example.com",
       @verifier_email="verifier@example.com",
       @whitelist_validation=false,
       @whitelisted_domains=[]>,
  @validation_type=:mx>
```

#### MX blacklist validation

MX blacklist validation is the third validation level. This layer checks the mail server IP address(es) extracted during MX validation against a predefined list of blacklisted IP addresses. It can be used as part of DEA ([disposable email address](https://en.wikipedia.org/wiki/Disposable_email_address)) validation.

```code
[Whitelist/Blacklist] -> [Regex validation] -> [MX validation] -> [MX blacklist validation]
```

Example of usage:

```ruby
require 'truemail'

Truemail.configure do |config|
  config.verifier_email = 'verifier@example.com'
  config.blacklisted_mx_ip_addresses = %w[127.0.1.2]
end

Truemail.validate('email@example.com', with: :mx_blacklist)

=> #<Truemail::Validator:0x00007fca0c8aea70
 @result=
  #<struct Truemail::Validator::Result
   success=false,
   email="email@example.com",
   domain="example.com",
   mail_servers=["127.0.1.1", "127.0.1.2"],
   errors={:mx_blacklist=>"blacklisted mx server ip address"},
   smtp_debug=nil,
   configuration=
    #<Truemail::Configuration:0x00007fca0c8aeb38
     @whitelisted_emails=[],
     @blacklisted_emails=[],
     @blacklisted_domains=[],
     @blacklisted_mx_ip_addresses=["127.0.1.2"],
     @connection_attempts=2,
     @connection_timeout=2,
     @default_validation_type=:smtp,
     @dns=[],
     @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-.+]*)@((?i-mx:[\p{L}0-9]+([\-.]{1}[\p{L}0-9]+)*\.\p{L}{2,63}))\z)/,
     @not_rfc_mx_lookup_flow=false,
     @response_timeout=2,
     @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
     @smtp_port=25,
     @smtp_fail_fast=false,
     @smtp_safe_check=false,
     @validation_type_by_domain={},
     @verifier_domain="example.com",
     @verifier_email="verifier@example.com",
     @whitelist_validation=false,
     @whitelisted_domains=[]>>,
 @validation_type=:mx_blacklist>
```

#### SMTP validation

SMTP validation is the final, fourth validation level. This type of validation tries to check the real existence of the email account on the target mail server. It runs the chain of previous validations and, if they complete successfully, runs itself.

```code
[Whitelist/Blacklist] -> [Regex validation] -> [MX validation] -> [MX blacklist validation] -> [SMTP validation]
```

If there is exactly one MX server, the `Truemail::Smtp` validator will use the value of `Truemail.configuration.connection_attempts` as the number of connection attempts. It defaults to `2`.

By default you don't need to pass the `with:` parameter to use it. Examples of usage are below:

##### SMTP fail fast enabled

Truemail can use fail-fast behavior for the SMTP validation layer. When `smtp_fail_fast = true`, `truemail` ends the SMTP validation session after the first attempt on the first MX server in any failure case (network connection/timeout error, SMTP validation error). This feature helps reduce the total time of an SMTP validation session to about 1 second.

```ruby
require 'truemail'

Truemail.configure do |config|
  config.verifier_email = 'verifier@example.com'
  config.smtp_fail_fast = true
end

Truemail.validate('email@example.com')

# SMTP validation failed, smtp fail fast validation scenario
=> #<Truemail::Validator:0x00007fdc4504f460
    @result=
      #<struct Truemail::Validator::Result
        success=false,
        email="email@example.com",
        domain="example.com",
        mail_servers=["127.0.1.1", "127.0.1.2", "127.0.1.3"], # there are 3 mail servers in a row
        errors={:smtp=>"smtp error"},
        smtp_debug=
          [#<Truemail::Validate::Smtp::Request:0x00007fdc43150b90 # but iteration stopped after the first failure
            @attempts=nil,
            @configuration=
              #<Truemail::Validate::Smtp::Request::Configuration:0x00007fdc43150b18
                @connection_timeout=2,
                @response_timeout=2,
                @verifier_domain="example.com",
                @verifier_email="verifier@example.com">,
            @email="email@example.com",
            @host="127.0.1.1",
            @response=
              #<struct Truemail::Validate::Smtp::Response
                port_opened=false,
                connection=nil,
                helo=nil,
                mailfrom=nil,
                rcptto=nil,
                errors={}>>],
        configuration=
          #<Truemail::Configuration:0x00007fdc4504f5c8
            @whitelisted_emails=[],
            @blacklisted_emails=[],
            @blacklisted_domains=[],
            @blacklisted_mx_ip_addresses=[],
            @dns=[],
            @connection_attempts=2,
            @connection_timeout=2,
            @default_validation_type=:smtp,
            @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-.+]*)@((?i-mx:[\p{L}0-9]+([\-.]{1}[\p{L}0-9]+)*\.\p{L}{2,63}))\z)/,
            @not_rfc_mx_lookup_flow=false,
            @response_timeout=2,
            @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
            @smtp_port=25,
            @smtp_fail_fast=true,
            @smtp_safe_check=false,
            @validation_type_by_domain={},
            @verifier_domain="example.com",
            @verifier_email="verifier@example.com",
            @whitelist_validation=false,
            @whitelisted_domains=[]>>,
      @validation_type=:smtp>
```

##### SMTP safe check disabled

With `smtp_safe_check = false`

```ruby
require 'truemail'

Truemail.configure do |config|
  config.verifier_email = 'verifier@example.com'
end

Truemail.validate('email@example.com')

# Successful SMTP validation
=> #<Truemail::Validator:0x000055590c4dc118
  @result=
    #<struct Truemail::Validator::Result
      success=true,
      email="email@example.com",
      domain="example.com",
      mail_servers=["127.0.1.1", "127.0.1.2"],
      errors={},
      smtp_debug=nil>,
      configuration=
      #<Truemail::Configuration:0x00005615e87b9298
       @whitelisted_emails=[],
       @blacklisted_emails=[],
       @blacklisted_domains=[],
       @blacklisted_mx_ip_addresses=[],
       @dns=[],
       @connection_attempts=2,
       @connection_timeout=2,
       @default_validation_type=:smtp,
       @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
       @response_timeout=2,
       @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
       @not_rfc_mx_lookup_flow=false,
       @smtp_fail_fast=false,
       @smtp_safe_check=false,
       @validation_type_by_domain={},
       @verifier_domain="example.com",
       @verifier_email="verifier@example.com",
       @whitelist_validation=false,
       @whitelisted_domains=[]>,
  @validation_type=:smtp>

# SMTP validation failed
=> #<Truemail::Validator:0x0000000002d5cee0
    @result=
      #<struct Truemail::Validator::Result
        success=false,
        email="email@example.com",
        domain="example.com",
        mail_servers=["127.0.1.1", "127.0.1.2"],
        errors={:smtp=>"smtp error"},
        smtp_debug=
          [#<Truemail::Validate::Smtp::Request:0x0000000002d49b10
            @configuration=
              #<Truemail::Validate::Smtp::Request::Configuration:0x00005615e8d21848
              @connection_timeout=2,
              @response_timeout=2,
              @verifier_domain="example.com",
              @verifier_email="verifier@example.com">,
            @email="email@example.com",
            @host="127.0.1.1",
            @attempts=nil,
            @response=
              #<struct Truemail::Validate::Smtp::Response
                port_opened=true,
                connection=true,
                helo=true,
                mailfrom=
                  #<Net::SMTP::Response:0x0000000002d5a618
                    @status="250",
                    @string="250 OK\n">,
                rcptto=false,
                errors={:rcptto=>"550 User not found\n"}>>]>,
          configuration=
            #<Truemail::Configuration:0x00005615e87b9298
             @whitelisted_emails=[],
             @blacklisted_emails=[],
             @blacklisted_domains=[],
             @blacklisted_mx_ip_addresses=[],
             @dns=[],
             @connection_attempts=2,
             @connection_timeout=2,
             @default_validation_type=:smtp,
             @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
             @response_timeout=2,
             @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
             @not_rfc_mx_lookup_flow=false,
             @smtp_port=25,
             @smtp_fail_fast=false,
             @smtp_safe_check=false,
             @validation_type_by_domain={},
             @verifier_domain="example.com",
             @verifier_email="verifier@example.com",
             @whitelist_validation=false,
             @whitelisted_domains=[]>,
    @validation_type=:smtp>
```

##### SMTP safe check enabled

With `smtp_safe_check = true`

```ruby
require 'truemail'

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
        mail_servers=["127.0.1.1", "127.0.1.2"],
        errors={},
        smtp_debug=
          [#<Truemail::Validate::Smtp::Request:0x0000000002c95d40
            @configuration=
              #<Truemail::Validate::Smtp::Request::Configuration:0x00005615e8d21848
              @connection_timeout=2,
              @response_timeout=2,
              @verifier_domain="example.com",
              @verifier_email="verifier@example.com">,
            @email="email@example.com",
            @host="127.0.1.1",
            @attempts=nil,
            @response=
              #<struct Truemail::Validate::Smtp::Response
                port_opened=true,
                connection=false,
                helo=true,
                mailfrom=false,
                rcptto=nil,
                errors={:mailfrom=>"554 5.7.1 Client host blocked\n", :connection=>"server dropped connection after response"}>>,]>,
        configuration=
            #<Truemail::Configuration:0x00005615e87b9298
             @whitelisted_emails=[],
             @blacklisted_emails=[],
             @blacklisted_domains=[],
             @blacklisted_mx_ip_addresses=[],
             @dns=[],
             @connection_attempts=2,
             @connection_timeout=2,
             @default_validation_type=:smtp,
             @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
             @response_timeout=2,
             @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
             @not_rfc_mx_lookup_flow=false,
             @smtp_fail_fast=false,
             @smtp_safe_check=false,
             @validation_type_by_domain={},
             @verifier_domain="example.com",
             @verifier_email="verifier@example.com",
             @whitelist_validation=false,
             @whitelisted_domains=[]>,
    @validation_type=:smtp>

# SMTP validation failed
=> #<Truemail::Validator:0x0000000002d5cee0
   @result=
    #<struct Truemail::Validator::Result
      success=false,
      email="email@example.com",
      domain="example.com",
      mail_servers=["127.0.1.1", "127.0.1.2"],
      errors={:smtp=>"smtp error"},
      smtp_debug=
        [#<Truemail::Validate::Smtp::Request:0x0000000002d49b10
          @configuration=
              #<Truemail::Validate::Smtp::Request::Configuration:0x00005615e8d21848
              @connection_timeout=2,
              @response_timeout=2,
              @verifier_domain="example.com",
              @verifier_email="verifier@example.com">,
          @email="email@example.com",
          @host="127.0.1.1",
          @attempts=nil,
          @response=
            #<struct Truemail::Validate::Smtp::Response
              port_opened=true,
              connection=true,
              helo=true,
              mailfrom=#<Net::SMTP::Response:0x0000000002d5a618 @status="250", @string="250 OK\n">,
              rcptto=false,
              errors={:rcptto=>"550 User not found\n"}>>]>,
      configuration=
            #<Truemail::Configuration:0x00005615e87b9298
             @whitelisted_emails=[],
             @blacklisted_emails=[],
             @blacklisted_domains=[],
             @blacklisted_mx_ip_addresses=[],
             @dns=[],
             @connection_attempts=2,
             @connection_timeout=2,
             @default_validation_type=:smtp,
             @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
             @response_timeout=2,
             @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
             @not_rfc_mx_lookup_flow=false,
             @smtp_port=25,
             @smtp_fail_fast=false,
             @smtp_safe_check=false,
             @validation_type_by_domain={},
             @verifier_domain="example.com",
             @verifier_email="verifier@example.com",
             @whitelist_validation=false,
             @whitelisted_domains=[]>,
    @validation_type=:smtp>
```

### Host audit features

The Truemail gem can audit the host it runs on. This helps detect common host problems that interfere with proper email verification.

#### IP audit

Checks whether the current Truemail host has a working internet connection and detects the current host IP address.

#### DNS audit

Checks whether the verifier domain points to the current Truemail host IP address.

#### PTR audit

So what is a PTR record? A PTR record, or pointer record, enables someone to perform a reverse DNS lookup. This allows them to determine your domain name based on your IP address. Because generic domain names without a PTR record are often associated with spammers, incoming mail servers identify email from hosts without PTR records as spam, and you can't verify your emails reliably.

Checks whether a PTR record exists for your Truemail host IP address and whether it points to the current verifier domain.

#### Usage example

```ruby
Truemail.host_audit
# Everything is good
=> #<Truemail::Auditor:0x00005580df358828
   @result=
     #<struct Truemail::Auditor::Result
       current_host_ip="127.0.0.1",
       warnings={}>,
       configuration=
        #<Truemail::Configuration:0x00005615e86327a8
         @whitelisted_emails=[],
         @blacklisted_emails=[],
         @blacklisted_domains=[],
         @blacklisted_mx_ip_addresses=[],
         @dns=[],
         @connection_attempts=2,
         @connection_timeout=2,
         @default_validation_type=:smtp,
         @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
         @response_timeout=2,
         @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
         @not_rfc_mx_lookup_flow=false,
         @smtp_port=25,
         @smtp_fail_fast=false,
         @smtp_safe_check=false,
         @validation_type_by_domain={},
         @verifier_domain="example.com",
         @verifier_email="verifier@example.com",
         @whitelist_validation=false,
         @whitelisted_domains=[]>

# Has audit warnings
=> #<Truemail::Auditor:0x00005580df358828
   @result=
     #<struct Truemail::Auditor::Result
       current_host_ip="127.0.0.1",
       warnings={
         :dns=>"A record of verifier domain does not refer to current host IP address",
         :ptr=>"PTR record does not refer to current verifier domain"
       },
       configuration=
        #<Truemail::Configuration:0x00005615e86327a8
         @whitelisted_emails=[],
         @blacklisted_emails=[],
         @blacklisted_domains=[],
         @blacklisted_mx_ip_addresses=[],
         @dns=[],
         @connection_attempts=2,
         @connection_timeout=2,
         @default_validation_type=:smtp,
         @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
         @response_timeout=2,
         @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
         @not_rfc_mx_lookup_flow=false,
         @smtp_port=25,
         @smtp_fail_fast=false,
         @smtp_safe_check=false,
         @validation_type_by_domain={},
         @verifier_domain="example.com",
         @verifier_email="verifier@example.com",
         @whitelist_validation=false,
         @whitelisted_domains=[]>
```

### Event logger

The Truemail gem can output tracking events to stdout, to a file, or both. Please note that at least one of the outputs (stdout or a file path) must be configured. The default tracking event is `:error`.

```ruby
Truemail.configure do |config|
  config.logger = {
    tracking_event: :all,
    stdout: true,
    log_absolute_path: '/home/app/log/truemail.log'
    }
end
```

#### Using custom logger

By default Truemail uses `Logger`, the default logger from the Ruby stdlib. You can override this behavior by passing your own logger instance in the event logger configuration. Please note that your logger instance should have the same interface as the built-in stdlib `Logger`. In this case `custom_logger` is the only required field in the logger configuration (you don't have to use `stdout` and `log_absolute_path`).

```ruby
Truemail.configure do |config|
  config.logger = { custom_logger: MyCustomLogger.new }
end
```

#### Available tracking events

- `:all`, all detected events, including successful validations
- `:unrecognized_error`, unrecognized errors only (when `smtp_safe_check = true` and the SMTP server does not return an explicit answer that the email does not exist)
- `:recognized_error`, recognized errors only
- `:error`, recognized and unrecognized errors only

### JSON serializers

Truemail has built-in JSON serializers for `Truemail::Auditor` and `Truemail::Validator` instances, so you can represent your host audit or email validation result as JSON. You can also use the [#as_json](#as_json) helper as a shortcut.

#### Auditor JSON serializer

```ruby
Truemail::Log::Serializer::AuditorJson.call(Truemail.host_audit)

=>
# Serialized Truemail::Auditor instance
{
  "date": "2020-08-31 22:33:43 +0300",
  "current_host_ip": "127.0.0.1",
  "warnings": {
    "dns": "A record of verifier domain does not refer to current host IP address", "ptr": "PTR record does not refer to current verifier domain"
  },
 "configuration": {
    "whitelisted_emails": null,
    "blacklisted_emails": null,
    "blacklisted_domains": null,
    "blacklisted_mx_ip_addresses": null,
    "dns": null,
    "email_pattern": "default gem value",
    "not_rfc_mx_lookup_flow": false,
    "smtp_error_body_pattern": "default gem value",
    "smtp_fail_fast": false,
    "smtp_safe_check": false,
    "validation_type_by_domain": null,
    "whitelist_validation": false,
    "whitelisted_domains": null
  }
}
```

#### Validator JSON serializer

```ruby
Truemail::Log::Serializer::ValidatorJson.call(Truemail.validate('nonexistent_email@bestweb.com.ua'))

=>
# Serialized Truemail::Validator instance
{
  "date": "2019-10-28 10:15:51 +0200",
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
    "whitelisted_emails": null,
    "blacklisted_emails": null,
    "blacklisted_domains": null,
    "blacklisted_mx_ip_addresses": null,
    "dns": null,
    "email_pattern": "default gem value",
    "not_rfc_mx_lookup_flow": false,
    "smtp_error_body_pattern": "default gem value",
    "smtp_fail_fast": false,
    "smtp_safe_check": false,
    "validation_type_by_domain": null,
    "whitelist_validation": false,
    "whitelisted_domains": null
  }
}
```

### Truemail helpers

#### `.valid?`

You can use the `.valid?` helper for quick validation of an email address. It returns a boolean:

```ruby
# It is a shortcut for Truemail.validate('email@example.com').result.valid?
Truemail.valid?('email@example.com')
=> true
```

#### `#as_json`

You can use the `#as_json` helper to represent `Truemail::Auditor` or `Truemail::Validator` instances as JSON. Under the hood it uses the internal `Truemail::Log::Serializer::AuditorJson` and `Truemail::Log::Serializer::ValidatorJson` JSON [serializers](#json-serializers):

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
    "whitelisted_emails": null,
    "blacklisted_emails": null,
    "blacklisted_domains": null,
    "blacklisted_mx_ip_addresses": null,
    "dns": null,
    "email_pattern": "default gem value",
    "not_rfc_mx_lookup_flow": false,
    "smtp_error_body_pattern": "default gem value",
    "smtp_fail_fast": false,
    "smtp_safe_check": false,
    "validation_type_by_domain": null,
    "whitelist_validation": false,
    "whitelisted_domains": null
  }
}


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
    "whitelisted_emails": null,
    "blacklisted_emails": null,
    "blacklisted_domains": null,
    "blacklisted_mx_ip_addresses": null,
    "dns": null,
    "email_pattern": "default gem value",
    "not_rfc_mx_lookup_flow": false,
    "smtp_error_body_pattern": "default gem value",
    "smtp_fail_fast": false,
    "smtp_safe_check": false,
    "validation_type_by_domain": null,
    "whitelist_validation": false,
    "whitelisted_domains": null
  }
}
```

### Test environment

You can stub out validation in your test environment. Just add an RSpec `before` hook:

```ruby
# spec_helper.rb

RSpec.configure do |config|
  config.before { allow(Truemail).to receive(:valid?).and_return(true) }
  # or
  config.before { allow(Truemail).to receive(:validate).and_return(true) }
  # or
  config.before { allow(Truemail).to receive_message_chain(:validate, :result, :valid?).and_return(true) }
end
```

Or, with the [whitelist/blacklist feature](#whitelistblacklist-check), you can define validation behavior for your test and staging environments:

```ruby
# config/initializers/truemail.rb

Truemail.configure do |config|
  config.verifier_email = Rails.configuration.default_sender_email

  unless Rails.env.production?
    config.whitelisted_domains = Constants::Email::WHITE_DOMAINS
    config.blacklisted_domains = Constants::Email::BLACK_DOMAINS
  end
end
```

Or you can take an end-to-end approach and mock the DNS and SMTP services with [`dns_mock`](https://github.com/mocktools/ruby-dns-mock) and [`smtp_mock`](https://github.com/mocktools/ruby-smtp-mock) in your test environment, as in the example below:

```ruby
# Gemfile

group :test do
  gem 'dns_mock', require: false
  gem 'smtp_mock', require: false
end

# spec/spec_helper.rb

require 'dns_mock/test_framework/rspec'
require 'smtp_mock/test_framework/rspec'

RSpec.configure do |config|
  config.include DnsMock::TestFramework::RSpec::Helper
  config.include SmtpMock::TestFramework::RSpec::Helper
end

# spec/integration_spec.rb

RSpec.describe 'integration tests' do
  let(:target_email) { random_email }
  let(:dns_mock_records) { dns_mock_records_by_email(target_email, dimension: 2) }

  before do
    dns_mock_server.assign_mocks(dns_mock_records)
    smtp_mock_server(**smtp_mock_server_options)

    Truemail.configuration.tap do |config|
      config.dns = %W[127.0.0.1:#{dns_mock_server.port}]
      config.smtp_port = smtp_mock_server.port
    end
  end

  context 'when checking a real email' do
    let(:smtp_mock_server_options) { {} }

    it { expect(Truemail.validate(target_email).result).to be_valid }
  end

  context 'when checking a fake email' do
    let(:smtp_mock_server_options) { { not_registered_emails: [target_email] } }

    it { expect(Truemail.validate(target_email).result).not_to be_valid }
  end
end
```

---

## Truemail family

All Truemail solutions: <https://truemail-rb.org>

| Name | Type | Description |
| --- | --- | --- |
| [truemail-go](https://github.com/truemail-rb/truemail-go) | go package | Configurable Go email validator, the main core |
| [truemail server](https://github.com/truemail-rb/truemail-rack) | ruby app | Lightweight Rack-based web API wrapper for the Truemail gem |
| [truemail-rack-docker](https://github.com/truemail-rb/truemail-rack-docker-image) | docker image | Lightweight Rack-based web API [Docker image](https://hub.docker.com/r/truemail/truemail-rack) :whale: of Truemail server |
| [truemail-ruby-client](https://github.com/truemail-rb/truemail-ruby-client) | ruby gem | Web API Ruby client for Truemail Server |
| [truemail-crystal-client](https://github.com/truemail-rb/truemail-crystal-client) | crystal shard | Web API Crystal client for Truemail Server |
| [truemail-java-client](https://github.com/truemail-rb/truemail-java-client) | java lib | Web API Java client for Truemail Server |
| [truemail-rspec](https://github.com/truemail-rb/truemail-rspec) | ruby gem | Truemail configuration, auditor and validator RSpec helpers |

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/truemail-rb/truemail>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct. Please check the [open tickets](https://github.com/truemail-rb/truemail/issues). Be sure to follow the Contributor Code of Conduct below and our [Contributing Guidelines](CONTRIBUTING.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Truemail project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Credits

- [The Contributors](https://github.com/truemail-rb/truemail/graphs/contributors) for code and awesome suggestions
- [The Stargazers](https://github.com/truemail-rb/truemail/stargazers) for showing their support

## Versioning

Truemail uses [Semantic Versioning 2.0.0](https://semver.org)
