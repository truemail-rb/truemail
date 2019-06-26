# Truemail

[![Maintainability](https://api.codeclimate.com/v1/badges/657aa241399927dcd2e2/maintainability)](https://codeclimate.com/github/rubygarage/truemail/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/657aa241399927dcd2e2/test_coverage)](https://codeclimate.com/github/rubygarage/truemail/test_coverage) [![CircleCI](https://circleci.com/gh/rubygarage/truemail/tree/master.svg?style=svg)](https://circleci.com/gh/rubygarage/truemail/tree/master) [![Gem Version](https://badge.fury.io/rb/truemail.svg)](https://badge.fury.io/rb/truemail) [![Downloads](https://img.shields.io/gem/dt/truemail.svg?colorA=004d99&colorB=0073e6)](https://rubygems.org/gems/truemail) [![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v1.4%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md)

The Truemail gem helps you validate emails by regex pattern, presence of domain mx-records, and real existence of email account on a current email server. Also Truemail gem allows performing an audit of the host in which runs.

## Features

- Configurable validator, validate only what you need
- Zero runtime dependencies
- Has whitelist/blacklist
- Has simple SMTP debugger
- 100% test coverage

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'truemail'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install truemail

## Email Validation Methods

Email validation is a tricky thing. There are a number of different ways to validate an email address and all mechanisms must conform with the best practices and provide proper validation.

**Syntax Checking**: Checks the email addresses via regex pattern.

**Mail Server Existence Check**: Checks the availability of the email address domain using DNS MX records.

**Mail Existence Check**: Checks if the email address really exists and can receive email via SMTP connections and email-sending emulation techniques.

## Usage

### Configuration features 

#### Set configuration

To have an access for ```Truemail.configuration``` and gem features, you must configure it first as in the example below:

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
  config.validation_type_for = { 'somedomain.com' => :regex, 'otherdomain.com' => :mx }

  # Optional parameter. Validation of email which contains whitelisted domain always will
  # return true. Other validations will not processed even if it was defined in validation_type_for
  config.whitelisted_domains = ['somedomain1.com', 'somedomain2.com']

  # Optional parameter. With this option Truemail will validate email which contains whitelisted
  # domain only, i.e. if domain whitelisted, validation will passed to Regex, MX or SMTP validators.
  # Validation of email which not contains whitelisted domain always will return false.
  config.whitelist_validation = true

  # Optional parameter. Validation of email which contains blacklisted domain always will
  # return false. Other validations will not processed even if it was defined in validation_type_for
  config.blacklisted_domains = ['somedomain1.com', 'somedomain2.com']

  # Optional parameter. This option will be parse bodies of SMTP errors. It will be helpful
  # if SMTP server does not return an exact answer that the email does not exist
  # By default this option is disabled, available for SMTP validation only.
  config.smtp_safe_check = true
end
```

#### Read configuration

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
 @smtp_safe_check=true>
```

#### Update configuration

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
 @smtp_safe_check=true>
```

#### Reset configuration

Also you can reset Truemail configuration.

```ruby
Truemail.reset_configuration!
=> nil
Truemail.configuration
=> nil
```

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
  @validation_type=:whitelist>
```

#### Regex validation

Validation with regex pattern is the first validation level. It uses whitelist/blacklist check before running itself.

```code
[Whitelist/Blacklist] -> [Regex validation]
```

By default this validation not performs strictly following [RFC 5322](https://www.ietf.org/rfc/rfc5322.txt) standard, so you can override Truemail default regex pattern if you want.

Example of usage:

1. With default regex pattern

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
  @validation_type=:regex>
```

2. With custom regex pattern. You should define your custom regex pattern in a gem configuration before.

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
  @validation_type=:regex>
```

#### MX validation

Validation by MX records is the second validation level. It uses Regex validation before running itself. When regex validation has completed successfully then runs itself.

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
  @validation_type=:mx>
```

#### SMTP validation

SMTP validation is a final, third validation level. This type of validation tries to check real existence of email account on a current email server. This validation runs a chain of previous validations and if they're complete successfully then runs itself.

```code
[Whitelist/Blacklist] -> [Regex validation] -> [MX validation] -> [SMTP validation]
```

If total count of MX servers is equal to one, ```Truemail::Smtp``` validator will use value from ```Truemail.configuration.connection_attempts``` as connection attempts. By default it's equal 2.

By default, you don't need pass with-parameter to use it. Example of usage is specified below:

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
              #<Truemail::Configuration:0x0000000002d49930
              @connection_timeout=2,
              @email_pattern=/regex_pattern/,
              @smtp_error_body_pattern=/regex_pattern/,
              @response_timeout=2,
              @connection_attempts=2,
              @smtp_safe_check=false,
              @validation_type_by_domain={},
              @whitelisted_domains=[],
              @whitelist_validation=false,
              @blacklisted_domains=[],
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
    @validation_type=:smtp>
```

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
              #<Truemail::Configuration:0x0000000002c95b38
                @connection_timeout=2,
                @email_pattern=/regex_pattern/,
                @smtp_error_body_pattern=/regex_pattern/,
                @response_timeout=2,
                @connection_attempts=2,
                @smtp_safe_check=true,
                @validation_type_by_domain={},
                @whitelisted_domains=[],
                @whitelist_validation=false,
                @blacklisted_domains=[],
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
            #<Truemail::Configuration:0x0000000002d49930
              @connection_timeout=2,
              @email_pattern=/regex_pattern/,
              @smtp_error_body_pattern=/regex_pattern/,
              @response_timeout=2,
              @connection_attempts=2,
              @smtp_safe_check=true,
              @validation_type_by_domain={},
              @whitelisted_domains=[],
              @whitelist_validation=false,
              @blacklisted_domains=[],
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
    @validation_type=:smtp>
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
       warnings={}>>

# Has PTR warning
=> #<Truemail::Auditor:0x00005580df358828
   @result=
     #<struct Truemail::Auditor::Result
       warnings=
         {:ptr=>"ptr record does not reference to current verifier domain"}>>
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

---
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubygarage/truemail. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct. Please check the [open tikets](https://github.com/rubygarage/truemail/issues). Be shure to follow Contributor Code of Conduct below and our [Contributing Guidelines](CONTRIBUTING.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Truemail project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Versioning

Truemail uses [Semantic Versioning 2.0.0](https://semver.org)

---
<a href="https://rubygarage.org/"><img src="https://rubygarage.s3.amazonaws.com/assets/assets/rg_color_logo_horizontal-919afc51a81d2e40cb6a0b43ee832e3fcd49669d06785156d2d16fd0d799f89e.png" alt="RubyGarage Logo" width="415" height="128"></a>

RubyGarage is a leading software development and consulting company in Eastern Europe. Our main expertise includes Ruby and Ruby on Rails, but we successfully employ other technologies to deliver the best results to our clients. [Check out our portfolio](https://rubygarage.org/portfolio) for even more exciting works!
