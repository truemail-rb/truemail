# <img src='https://repository-images.githubusercontent.com/173723932/6dffee00-e88e-11e9-94b6-c97aacc0df00' height='250' alt='Truemail - configurable framework agnostic plain Ruby email validator' />

[![Maintainability](https://api.codeclimate.com/v1/badges/657aa241399927dcd2e2/maintainability)](https://codeclimate.com/github/rubygarage/truemail/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/657aa241399927dcd2e2/test_coverage)](https://codeclimate.com/github/rubygarage/truemail/test_coverage) [![CircleCI](https://circleci.com/gh/rubygarage/truemail/tree/master.svg?style=svg)](https://circleci.com/gh/rubygarage/truemail/tree/master) [![Gem Version](https://badge.fury.io/rb/truemail.svg)](https://badge.fury.io/rb/truemail) [![Downloads](https://img.shields.io/gem/dt/truemail.svg?colorA=004d99&colorB=0073e6)](https://rubygems.org/gems/truemail) [![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v1.4%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md)

Configurable framework agnostic plain Ruby email validator. Verify email via Regex, DNS and SMTP. Be sure that email address valid and exists.

## Table of Contents

- [Synopsis](#synopsis)
- [Features](#features)
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
    - [SMTP validation](#smtp-validation)
      - [SMTP safe check disabled](#smtp-safe-check-disabled)
      - [SMTP safe check enabled](#smtp-safe-check-enabled)
  - [Event logger](#event-logger)
    - [Available tracking events](#available-tracking-events)
  - [JSON serializer](#json-serializer)
  - [Host audit features](#host-audit-features)
    - [PTR audit](#ptr-audit)
  - [Truemail helpers](#truemail-helpers)
    - [.valid?](#valid)
  - [Test environment](#test-environment)
- [Truemail family](#truemail-family)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)
- [Credits](#credits)
- [Versioning](#versioning)
- [Changelog](CHANGELOG.md)
- [Wiki](https://github.com/rubygarage/truemail/wiki)

## Synopsis

Email validation is a tricky thing. There are a number of different ways to validate an email address and all mechanisms must conform with the best practices and provide proper validation. You can get more information about email validation techniques in our [blog](https://rubygarage.org/blog/how-to-validate-emails). The Truemail gem helps you validate emails via regex pattern, presence of DNS records, and real existence of email account on a current email server.

**Syntax Checking**: Checks the email addresses via regex pattern.

**Mail Server Existence Check**: Checks the availability of the email address domain using DNS records.

**Mail Existence Check**: Checks if the email address really exists and can receive email via SMTP connections and email-sending emulation techniques.

Also Truemail gem allows performing an audit of the host in which runs.

## Features

- Configurable validator, validate only what you need
- Minimal runtime dependencies
- Supporting of internationalized emails ([EAI](https://en.wikipedia.org/wiki/Email_address#Internationalization))
- Whitelist/blacklist validation layers
- Simple SMTP debugger
- Event logger
- JSON serializer

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'truemail'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install truemail

## Usage

### Configuration features

You can use global gem configuration or custom independent configuration. Available configuration options:

- verifier email
- verifier domain
- email pattern
- SMTP error body pattern
- connection timeout
- response timeout
- connection attempts
- default validation type
- validation type for domains
- whitelisted domains
- whitelist validation
- blacklisted domains
- SMTP safe check
- event logger
- JSON serializer

#### Setting global configuration

To have an access for ```Truemail.configuration``` and gem configuration features, you must configure it first as in the example below:

```ruby
require 'truemail'

Truemail.configure do |config|
  # Required parameter. Must be an existing email on behalf of which verification will be performed
  config.verifier_email = 'verifier@example.com'

  # Optional parameter. Must be an existing domain on behalf of which verification will be performed.
  # By default verifier domain based on verifier email
  config.verifier_domain = 'somedomain.com'

  # Optional parameter. You can override default regex pattern
  config.email_pattern = /regex_pattern/

  # Optional parameter. You can override default regex pattern
  config.smtp_error_body_pattern = /regex_pattern/

  # Optional parameter. Connection timeout is equal to 2 ms by default.
  config.connection_timeout = 1

  # Optional parameter. A SMTP server response timeout is equal to 2 ms by default.
  config.response_timeout = 1

  # Optional parameter. Total of connection attempts. It is equal to 2 by default.
  # This parameter uses in mx lookup timeout error and smtp request (for cases when
  # there is one mx server).
  config.connection_attempts = 3

  # Optional parameter. You can predefine default validation type for
  # Truemail.validate('email@email.com') call without with-parameter
  # Available validation types: :regex, :mx, :smtp
  config.default_validation_type = :mx

  # Optional parameter. You can predefine which type of validation will be used for domains.
  # Also you can skip validation by domain. Available validation types: :regex, :mx, :smtp
  # This configuration will be used over current or default validation type parameter
  # All of validations for 'somedomain.com' will be processed with regex validation only.
  # And all of validations for 'otherdomain.com' will be processed with mx validation only.
  # It is equal to empty hash by default.
  config.validation_type_for = { 'somedomain.com' => :regex, 'otherdomain.com' => :mx }

  # Optional parameter. Validation of email which contains whitelisted domain always will
  # return true. Other validations will not processed even if it was defined in validation_type_for
  # It is equal to empty array by default.
  config.whitelisted_domains = ['somedomain1.com', 'somedomain2.com']

  # Optional parameter. With this option Truemail will validate email which contains whitelisted
  # domain only, i.e. if domain whitelisted, validation will passed to Regex, MX or SMTP validators.
  # Validation of email which not contains whitelisted domain always will return false.
  # It is equal false by default.
  config.whitelist_validation = true

  # Optional parameter. Validation of email which contains blacklisted domain always will
  # return false. Other validations will not processed even if it was defined in validation_type_for
  # It is equal to empty array by default.
  config.blacklisted_domains = ['somedomain1.com', 'somedomain2.com']

  # Optional parameter. This option will be parse bodies of SMTP errors. It will be helpful
  # if SMTP server does not return an exact answer that the email does not exist
  # By default this option is disabled, available for SMTP validation only.
  config.smtp_safe_check = true

  # Optional parameter. This option will enable tracking events. You can print tracking events to
  # stdout, write to file or both of these. Tracking event by default is :error
  # Available tracking event: :all, :unrecognized_error, :recognized_error, :error
  config.logger = { tracking_event: :all, stdout: true, log_absolute_path: '/home/app/log/truemail.log' }
end
```

##### Read global configuration

After successful configuration, you can read current Truemail configuration instance anywhere in your application.

```ruby
Truemail.configuration

=> #<Truemail::Configuration:0x000055590cb17b40
 @connection_timeout=1,
 @email_pattern=/regex_pattern/,
 @smtp_error_body_pattern=/regex_pattern/,
 @response_timeout=1,
 @connection_attempts=3,
 @validation_type_by_domain={},
 @whitelisted_domains=[],
 @whitelist_validation=true,
 @blacklisted_domains=[],
 @verifier_domain="somedomain.com",
 @verifier_email="verifier@example.com"
 @smtp_safe_check=true,
 @logger=#<Truemail::Logger:0x0000557f837450b0
   @event=:all, @file="/home/app/log/truemail.log", @stdout=true>>
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
 @validation_type_by_domain={},
 @whitelisted_domains=[],
 @whitelist_validation=true,
 @blacklisted_domains=[],
 @verifier_domain="somedomain.com",
 @verifier_email="verifier@example.com",
 @smtp_safe_check=true,
 @logger=#<Truemail::Logger:0x0000557f837450b0
   @event=:all, @file="/home/app/log/truemail.log", @stdout=true>>
```

##### Reset global configuration

Also you can reset Truemail configuration.

```ruby
Truemail.reset_configuration!
=> nil
Truemail.configuration
=> nil
```

#### Using custom independent configuration

Allows to use independent configuration for each validation/audition instance. When using this feature you do not need to have Truemail global configuration.

```ruby
custom_configuration = Truemail::Configuration.new do |config|
  config.verifier_email = 'verifier@example.com'
end

Truemail.validate('email@example.com', custom_configuration: custom_configuration)
Truemail.valid?('email@example.com', custom_configuration: custom_configuration)
Truemail.host_audit('email@example.com', custom_configuration: custom_configuration)
```

Please note, you should have global or custom configuration for use Truemail gem.


### Validation features

#### Whitelist/Blacklist check

Whitelist/Blacklist check is zero validation level. You can define white and black list domains. It means that validation of email which contains whitelisted domain always will return ```true```, and for blacklisted domain will return ```false```.

Please note, other validations will not processed even if it was defined in ```validation_type_for```.

**Sequence of domain list check:**
1. Whitelist check
2. Whitelist validation check
3. Blacklist check

Example of usage:

```ruby
require 'truemail'

Truemail.configure do |config|
  config.verifier_email = 'verifier@example.com'
  config.whitelisted_domains = ['white-domain.com', 'somedomain.com']
  config.blacklisted_domains = ['black-domain.com', 'somedomain.com']
  config.validation_type_for = { 'somedomain.com' => :mx }
end
```

##### Whitelist case

When email in whitelist, validation type will be redefined. Validation result returns ```true```

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
    configuration=#<Truemail::Configuration:0x00005629f801bd28
     @blacklisted_domains=["black-domain.com", "somedomain.com"],
     @connection_attempts=2,
     @connection_timeout=2,
     @default_validation_type=:smtp,
     @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
     @response_timeout=2,
     @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
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
  config.whitelisted_domains = ['white-domain.com']
  config.whitelist_validation = true
end
```

When email domain in whitelist and ```whitelist_validation``` is sets equal to ```true``` validation type will be passed to other validators.
Validation of email which not contains whitelisted domain always will return ```false```.

###### Email has whitelisted domain

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
    configuration=
    #<Truemail::Configuration:0x0000563f0d2605c8
     @blacklisted_domains=[],
     @connection_attempts=2,
     @connection_timeout=2,
     @default_validation_type=:smtp,
     @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
     @response_timeout=2,
     @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
     @smtp_safe_check=false,
     @validation_type_by_domain={},
     @verifier_domain="example.com",
     @verifier_email="verifier@example.com",
     @whitelist_validation=true,
     @whitelisted_domains=["white-domain.com"]>,
  @validation_type=:regex>
```

###### Email hasn't whitelisted domain

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
    configuration=
    #<Truemail::Configuration:0x0000563f0cd82ab0
     @blacklisted_domains=[],
     @connection_attempts=2,
     @connection_timeout=2,
     @default_validation_type=:smtp,
     @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
     @response_timeout=2,
     @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
     @smtp_safe_check=false,
     @validation_type_by_domain={},
     @verifier_domain="example.com",
     @verifier_email="verifier@example.com",
     @whitelist_validation=true,
     @whitelisted_domains=["white-domain.com"]>,
  @validation_type=:blacklist>
```

##### Blacklist case

When email in blacklist, validation type will be redefined too. Validation result returns ```false```

```ruby
Truemail.validate('email@black-domain.com')

#<Truemail::Validator:0x000023y8429f3493
  @result=#<struct Truemail::Validator::Result
    success=false,
    email="email@black-domain.com",
    domain=nil,
    mail_servers=[],
    errors={},
    smtp_debug=nil>,
    configuration=
    #<Truemail::Configuration:0x0000563f0d36f4f0
     @blacklisted_domains=[],
     @connection_attempts=2,
     @connection_timeout=2,
     @default_validation_type=:smtp,
     @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
     @response_timeout=2,
     @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
     @smtp_safe_check=false,
     @validation_type_by_domain={},
     @verifier_domain="example.com",
     @verifier_email="verifier@example.com",
     @whitelist_validation=true,
     @whitelisted_domains=["white-domain.com"]>,
  @validation_type=:blacklist>
```

##### Duplication case

Validation result for this email returns ```true```, because it was found in whitelisted domains list first. Also ```validation_type``` for this case will be redefined.

```ruby
Truemail.validate('email@somedomain.com')

#<Truemail::Validator:0x000055b8429f3490
  @result=#<struct Truemail::Validator::Result
    success=true,
    email="email@somedomain.com",
    domain=nil,
    mail_servers=[],
    errors={},
    smtp_debug=nil>,
    configuration=
    #<Truemail::Configuration:0x0000563f0d3f8fc0
     @blacklisted_domains=[],
     @connection_attempts=2,
     @connection_timeout=2,
     @default_validation_type=:smtp,
     @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
     @response_timeout=2,
     @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
     @smtp_safe_check=false,
     @validation_type_by_domain={},
     @verifier_domain="example.com",
     @verifier_email="verifier@example.com",
     @whitelist_validation=true,
     @whitelisted_domains=["white-domain.com"]>,
  @validation_type=:whitelist>
```

#### Regex validation

Validation with regex pattern is the first validation level. It uses whitelist/blacklist check before running itself.

```code
[Whitelist/Blacklist] -> [Regex validation]
```

By default this validation not performs strictly following [RFC 5322](https://www.ietf.org/rfc/rfc5322.txt) standard, so you can override Truemail default regex pattern if you want.

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
      success=true, email="email@example.com",
      domain=nil,
      mail_servers=[],
      errors={},
      smtp_debug=nil>,
      configuration=
      #<Truemail::Configuration:0x000055aa56a54d48
       @blacklisted_domains=[],
       @connection_attempts=2,
       @connection_timeout=2,
       @default_validation_type=:smtp,
       @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
       @response_timeout=2,
       @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
       @smtp_safe_check=false,
       @validation_type_by_domain={},
       @verifier_domain="example.com",
       @verifier_email="verifier@example.com",
       @whitelist_validation=false,
       @whitelisted_domains=[]>,
  @validation_type=:regex>
```

##### With custom regex pattern

You should define your custom regex pattern in a gem configuration before.

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
      domain=nil,
      mail_servers=[],
      errors={},
      smtp_debug=nil>,
      configuration=
      #<Truemail::Configuration:0x0000560e58d80830
       @blacklisted_domains=[],
       @connection_attempts=2,
       @connection_timeout=2,
       @default_validation_type=:smtp,
       @email_pattern=/regex_pattern/,
       @response_timeout=2,
       @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
       @smtp_safe_check=false,
       @validation_type_by_domain={},
       @verifier_domain="example.com",
       @verifier_email="verifier@example.com",
       @whitelist_validation=false,
       @whitelisted_domains=[]>,
  @validation_type=:regex>
```

#### MX validation

In fact it's DNS validation because it checks not MX records only. DNS validation is the second validation level, historically named as MX validation. It uses Regex validation before running itself. When regex validation has completed successfully then runs itself.

```code
[Whitelist/Blacklist] -> [Regex validation] -> [MX validation]
```

Please note, Truemail MX validator not performs strict compliance of the [RFC 5321](https://tools.ietf.org/html/rfc5321#section-5) standard for best validation outcome.

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
       @blacklisted_domains=[],
       @connection_attempts=2,
       @connection_timeout=2,
       @default_validation_type=:smtp,
       @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
       @response_timeout=2,
       @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
       @smtp_safe_check=false,
       @validation_type_by_domain={},
       @verifier_domain="example.com",
       @verifier_email="verifier@example.com",
       @whitelist_validation=false,
       @whitelisted_domains=[]>,
  @validation_type=:mx>
```

#### SMTP validation

SMTP validation is a final, third validation level. This type of validation tries to check real existence of email account on a current email server. This validation runs a chain of previous validations and if they're complete successfully then runs itself.

```code
[Whitelist/Blacklist] -> [Regex validation] -> [MX validation] -> [SMTP validation]
```

If total count of MX servers is equal to one, ```Truemail::Smtp``` validator will use value from ```Truemail.configuration.connection_attempts``` as connection attempts. By default it's equal 2.

By default, you don't need pass with-parameter to use it. Example of usage is specified below:

###### SMTP safe check disabled

With ```smtp_safe_check = false```

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
       @blacklisted_domains=[],
       @connection_attempts=2,
       @connection_timeout=2,
       @default_validation_type=:smtp,
       @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
       @response_timeout=2,
       @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
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
                helo=
                  #<Net::SMTP::Response:0x0000000002d5aca8
                    @status="250",
                    @string="250 127.0.1.1 Hello example.com\n">,
                mailfrom=
                  #<Net::SMTP::Response:0x0000000002d5a618
                    @status="250",
                    @string="250 OK\n">,
                rcptto=false,
                errors={:rcptto=>"550 User not found\n"}>>]>,
          configuration=
            #<Truemail::Configuration:0x00005615e87b9298
             @blacklisted_domains=[],
             @connection_attempts=2,
             @connection_timeout=2,
             @default_validation_type=:smtp,
             @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
             @response_timeout=2,
             @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
             @smtp_safe_check=false,
             @validation_type_by_domain={},
             @verifier_domain="example.com",
             @verifier_email="verifier@example.com",
             @whitelist_validation=false,
             @whitelisted_domains=[]>,
    @validation_type=:smtp>
```


###### SMTP safe check enabled

With ```smtp_safe_check = true```

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
                helo=
                  #<Net::SMTP::Response:0x0000000002c934c8
                  @status="250",
                  @string="250 127.0.1.1\n">,
                mailfrom=false,
                rcptto=nil,
                errors={:mailfrom=>"554 5.7.1 Client host blocked\n", :connection=>"server dropped connection after response"}>>,]>,
        configuration=
            #<Truemail::Configuration:0x00005615e87b9298
             @blacklisted_domains=[],
             @connection_attempts=2,
             @connection_timeout=2,
             @default_validation_type=:smtp,
             @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
             @response_timeout=2,
             @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
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
              helo=
              #<Net::SMTP::Response:0x0000000002d5aca8
                @status="250",
                @string="250 127.0.1.1 Hello example.com\n">,
              mailfrom=#<Net::SMTP::Response:0x0000000002d5a618 @status="250", @string="250 OK\n">,
              rcptto=false,
              errors={:rcptto=>"550 User not found\n"}>>]>,
      configuration=
            #<Truemail::Configuration:0x00005615e87b9298
             @blacklisted_domains=[],
             @connection_attempts=2,
             @connection_timeout=2,
             @default_validation_type=:smtp,
             @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
             @response_timeout=2,
             @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
             @smtp_safe_check=false,
             @validation_type_by_domain={},
             @verifier_domain="example.com",
             @verifier_email="verifier@example.com",
             @whitelist_validation=false,
             @whitelisted_domains=[]>,
    @validation_type=:smtp>
```

### Event logger

Truemail gem allows to output tracking events to stdout/file or both of these. Please note, at least one of the outputs must exist. Tracking event by default is `:error`

```ruby
Truemail.configure do |config|
  config.logger = { tracking_event: :all, stdout: true, log_absolute_path: '/home/app/log/truemail.log' }
end
```

#### Available tracking events

- `:all`, all detected events including success validation cases
- `:unrecognized_error`, unrecognized errors only (when `smtp_safe_check = true` and SMTP server does not return an exact answer that the email does not exist)
- `:recognized_error`, recognized errors only
- `:error`, recognized and unrecognized errors only

### JSON serializer

Truemail has built in JSON serializer for `Truemail::Validator` instance, so you can represent your email validation result as json.

```ruby
Truemail::Log::Serializer::Json.call(Truemail.validate('nonexistent_email@bestweb.com.ua'))

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
    "validation_type_by_domain": null,
    "whitelist_validation": false,
    "whitelisted_domains": null,
    "blacklisted_domains": null,
    "smtp_safe_check": false,
    "email_pattern": "default gem value",
    "smtp_error_body_pattern": "default gem value"
  }
}
```

### Host audit features

Truemail gem allows performing an audit of the host in which runs. Only PTR record audit performs for today.

#### PTR audit

So what is a PTR record? A PTR record, or pointer record, enables someone to perform a reverse DNS lookup. This allows them to determine your domain name based on your IP address. Because generic domain names without a PTR are often associated with spammers, incoming mail servers identify email from hosts without PTR records as spam and you can't verify yours emails qualitatively.

```ruby
Truemail.host_audit
# Everything is good
=> #<Truemail::Auditor:0x00005580df358828
   @result=
     #<struct Truemail::Auditor::Result
       warnings={}>,
       configuration=
        #<Truemail::Configuration:0x00005615e86327a8
         @blacklisted_domains=[],
         @connection_attempts=2,
         @connection_timeout=2,
         @default_validation_type=:smtp,
         @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
         @response_timeout=2,
         @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
         @smtp_safe_check=false,
         @validation_type_by_domain={},
         @verifier_domain="example.com",
         @verifier_email="verifier@example.com",
         @whitelist_validation=false,
         @whitelisted_domains=[]>

# Has PTR warning
=> #<Truemail::Auditor:0x00005580df358828
   @result=
     #<struct Truemail::Auditor::Result
       warnings=
         {:ptr=>"ptr record does not reference to current verifier domain"}>,
       configuration=
        #<Truemail::Configuration:0x00005615e86327a8
         @blacklisted_domains=[],
         @connection_attempts=2,
         @connection_timeout=2,
         @default_validation_type=:smtp,
         @email_pattern=/(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\w|\-|\.|\+]*)@((?i-mx:[\p{L}0-9]+([\-\.]{1}[\p{L}0-9]+)*\.[\p{L}]{2,63}))\z)/,
         @response_timeout=2,
         @smtp_error_body_pattern=/(?=.*550)(?=.*(user|account|customer|mailbox)).*/i,
         @smtp_safe_check=false,
         @validation_type_by_domain={},
         @verifier_domain="example.com",
         @verifier_email="verifier@example.com",
         @whitelist_validation=false,
         @whitelisted_domains=[]>
```

### Truemail helpers

#### .valid?

You can use the ```.valid?``` helper for quick validation of email address. It returns a boolean:

```ruby
# It is shortcut for Truemail.validate('email@example.com').result.valid?
Truemail.valid?('email@example.com')
=> true
```

### Test environment

You can stub out that validation for your test environment. Just add RSpec before action:

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

Or with [whitelist/blacklist Truemail feature](#whitelistblacklist-check) you can define validation behavior for test and staging environment:

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

---
## Truemail family

All Truemail extensions: https://github.com/truemail-rb

### truemail-rspec

gem `truemail-rspec` - Truemail configuration and validator RSpec helpers, https://github.com/truemail-rb/truemail-rspec

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubygarage/truemail. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct. Please check the [open tikets](https://github.com/rubygarage/truemail/issues). Be shure to follow Contributor Code of Conduct below and our [Contributing Guidelines](CONTRIBUTING.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Truemail project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Credits

- [The Contributors](https://github.com/rubygarage/truemail/graphs/contributors) for code and awesome suggestions
- [The Stargazers](https://github.com/rubygarage/truemail/stargazers) for showing their support

## Versioning

Truemail uses [Semantic Versioning 2.0.0](https://semver.org)

---
<a href="https://rubygarage.org/"><img src="https://rubygarage.s3.amazonaws.com/assets/assets/rg_color_logo_horizontal-919afc51a81d2e40cb6a0b43ee832e3fcd49669d06785156d2d16fd0d799f89e.png" alt="RubyGarage Logo" width="415" height="128"></a>

RubyGarage is a leading software development and consulting company in Eastern Europe. Our main expertise includes Ruby and Ruby on Rails, but we successfully employ other technologies to deliver the best results to our clients. [Check out our portfolio](https://rubygarage.org/portfolio) for even more exciting works!
