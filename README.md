# Truemail

[![Maintainability](https://api.codeclimate.com/v1/badges/657aa241399927dcd2e2/maintainability)](https://codeclimate.com/github/rubygarage/truemail/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/657aa241399927dcd2e2/test_coverage)](https://codeclimate.com/github/rubygarage/truemail/test_coverage) [![Gem Version](https://badge.fury.io/rb/truemail.svg)](https://badge.fury.io/rb/truemail) [![CircleCI](https://circleci.com/gh/rubygarage/truemail/tree/master.svg?style=svg)](https://circleci.com/gh/rubygarage/truemail/tree/master)

The Truemail gem helps you validate emails by regex pattern, presence of domain mx-records, and real existence of email account on a current email server.

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

  # Optional parameter. Connection timeout is equal to 2 ms by default.
  config.connection_timeout = 1

  # Optional parameter. A SMTP server response timeout is equal to 2 ms by default.
  config.response_timeout = 1

  # Optional parameter. You can predefine which type of validation will be used for domains.
  # Available validation types: :regex, :mx, :smtp
  # This configuration will be used over current or default validation type parameter
  # All of validations for 'somedomain.com' will be processed with mx validation only
  config.validation_type_for = { 'somedomain.com' => :mx }

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
 @response_timeout=1,
 @validation_type_by_domain={},
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

Truemail.configuration
=> #<Truemail::Configuration:0x000055590cb17b40
 @connection_timeout=3,
 @email_pattern=/regex_pattern/,
 @response_timeout=4,
 @validation_type_by_domain={},
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

#### Regex validation

Validation with regex pattern is the first validation level.

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
  config.config.email_pattern = /regex_pattern/
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

Validation by MX records is second validation level. It uses Regex validation before launch. When regex validation has completed successfully then runs itself.

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
      mail_servers=["mx1.example.com", "mx2.example.com"],
      errors={},
      smtp_debug=nil>,
  @validation_type=:mx>
```

#### SMTP validation

SMTP validation is a final, third validation level. This type of validation tries to check real existence of email account on a current email server. This validation runs a chain of previous validations, and if they're complete, successfully runs itself.

```code
[Regex validation] -> [MX validation] -> [SMTP validation]
```

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
      mail_servers=["mx1.example.com", "mx2.example.com"],
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
        mail_servers=["mx1.example.com", "mx2.example.com", "mx3.example.com"],
        errors={:smtp=>"smtp error"},
        smtp_debug=
          [#<Truemail::Validate::Smtp::Request:0x0000000002d49b10
            @configuration=
              #<Truemail::Configuration:0x0000000002d49930
              @connection_timeout=2,
              @email_pattern=/regex_pattern/,
              @response_timeout=2,
              @smtp_safe_check=false,
              @validation_type_by_domain={},
              @verifier_domain="example.com",
              @verifier_email="verifier@example.com">,
            @email="email@example.com",
            @host="mx1.example.com",
            @response=
              #<struct Truemail::Validate::Smtp::Response
                port_opened=true,
                connection=true,
                helo=
                  #<Net::SMTP::Response:0x0000000002d5aca8
                    @status="250",
                    @string="250 mx1.example.com Hello example.com\n">,
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

# SMTP validation failed
=> #<Truemail::Validator:0x0000000002d5cee0
   @result=
    #<struct Truemail::Validator::Result
      success=false,
      email="email@example.com",
      domain="example.com",
      mail_servers=["mx1.example.com", "mx2.example.com", "mx3.example.com"],
      errors={:smtp=>"smtp error"},
      smtp_debug=
        [#<Truemail::Validate::Smtp::Request:0x0000000002d49b10
          @configuration=
            #<Truemail::Configuration:0x0000000002d49930
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
              connection=true,
              helo=
              #<Net::SMTP::Response:0x0000000002d5aca8
                @status="250",
                @string="250 mx1.example.com Hello example.com\n">,
              mailfrom=#<Net::SMTP::Response:0x0000000002d5a618 @status="250", @string="250 OK\n">,
              rcptto=false,
              errors={:rcptto=>"550 User not found\n"}>>]>,
    @validation_type=:smtp>
```

## ToDo

1. Gem compatibility with Ruby 2.3
2. Fail validations logger
3. The ability to use a proxy

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubygarage/truemail. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Truemail project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/truemail/blob/master/CODE_OF_CONDUCT.md).

---
<a href="https://rubygarage.org/"><img src="https://rubygarage.s3.amazonaws.com/assets/assets/rg_color_logo_horizontal-919afc51a81d2e40cb6a0b43ee832e3fcd49669d06785156d2d16fd0d799f89e.png" alt="RubyGarage Logo" width="415" height="128"></a>

RubyGarage is a leading software development and consulting company in Eastern Europe. Our main expertise includes Ruby and Ruby on Rails, but we successfully employ other technologies to deliver the best results to our clients. [Check out our portfolio](https://rubygarage.org/portfolio) for even more exciting works!
