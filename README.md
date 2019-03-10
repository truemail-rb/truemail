# Truemail

The main idea of this gem is to validate emails by regex pattern, presence of domain mx-records, and real existence of email account on a current email server.

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

Email validation is a tricky thing to do properly. There are a number of different ways to validate an email address. All checking mechanisms conform to best practices, and provide confident validation.

**Syntax Checking**: This checks the email addresses via regex pattern.

**Mail Server Existence Check**: This checks the availability of the email address domain using DNS MX records.

**Mail Existence Check**: This checks if the email address really exists and can receive email via SMTP connections and email-sending emulation techniques.

## Usage

TODO: Complete usage instructions here.

```ruby
Truemail.configure do |config|
  # Required parameter. It should be an existing email on behalf of which verification will be performed
  config.verifier_email = 'email@example.com'

  # Optional parameter. It should be an existing domain on behalf of which verification will be performed. By default verifier domain based on verifier email
  # config.verifier_domain = 'somedomain.com'

  # Optional parameter. You can override default regex pattern
  # config.email_pattern = /regex_pattern/
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubygarage/truemail. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Truemail project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/truemail/blob/master/CODE_OF_CONDUCT.md).

---
<a href="https://rubygarage.org/"><img src="https://rubygarage.s3.amazonaws.com/assets/assets/rg_color_logo_horizontal-919afc51a81d2e40cb6a0b43ee832e3fcd49669d06785156d2d16fd0d799f89e.png" alt="RubyGarage Logo" width="415" height="128"></a>

RubyGarage is a leading software development and consulting company in Eastern Europe. Our main expertise includes Ruby and Ruby on Rails, but we successfully employ other technologies to deliver the best results to our clients. [Check out our portfolio](https://rubygarage.org/portfolio) for even more exciting works!
