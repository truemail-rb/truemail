module Truemail
  module RegexConstant
    REGEX_DOMAIN = /[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,7}/
    REGEX_EMAIL_PATTERN = /(?=\A.{6,255}\z)(\A([\w|\-|\.]+)@(#{REGEX_DOMAIN})\z)/
    REGEX_DOMAIN_PATTERN = /(?=\A.{4,255}\z)(\A#{REGEX_DOMAIN}\z)/
  end
end
