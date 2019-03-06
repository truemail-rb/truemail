module Truemail
  RSpec.describe Configuration do
    describe '.new' do
      specify { expect(subject).to be_an_instance_of(Configuration) }
      include_examples 'has attr_accessor'
      include_examples 'sets default configuration'
    end

    describe 'configuration cases' do
      let(:valid_email) { 'email@42.subdomain.domain' }

      context 'auto configuration' do
        before { subject.verifier_email = valid_email }

        it 'sets default regex pattern' do
          expect(subject.email_pattern).to be_an_instance_of(Regexp)
        end

        it 'sets verifier email' do
          expect(subject.verifier_email).to eq(valid_email)
        end

        it 'sets verifier domain based on verifier email' do
          expect(subject.verifier_domain).to eq('42.subdomain.domain')
        end

        it 'configuration become complete' do
          expect(subject.complete?).to be(true)
        end
      end

      context 'manual independent configuration' do
        describe '#verifier_email=' do
          %w[i@i.co i-i_@42.subdomain.do-main.co 42@42.co].each do |email|
            context "with valid email #{email}" do
              before { subject.verifier_email = email }
              specify { expect(subject.verifier_email).to eq(email) }
            end
          end

          %w[email.com 1@42 i@localhost mail@do_main.us mail!@1.co].each do |email|
            context "with invalid email #{email}" do
              specify do
                expect { subject.verifier_email = email }
                  .to raise_error(Truemail::Configuration::ArgumentError)
              end
            end
          end
        end

        describe '#verifier_domain=' do
          %w[i.us 1.co 1.subdomain.domain 42.i.subdomain.domain true-domain.com].each do |domain|
            context "with valid domain #{domain}" do
              before { subject.verifier_domain = domain }
              specify { expect(subject.verifier_domain).to eq(domain) }
            end
          end

          %w[1.a domain hello.2c subdomain.longltdzone DOMAIN.com @do!ma,in.com dash_name.pro].each do |domain|
            context "with invalid domain #{domain}" do
              specify do
                expect { subject.verifier_domain = domain }
                  .to raise_error(Truemail::Configuration::ArgumentError)
              end
            end
          end
        end

        describe '#email_pattern=' do
          context 'with valid value' do
            let(:value) { /\d+/ }
            before { subject.email_pattern = value }
            specify { expect(subject.email_pattern).to eq(value) }
          end

          context 'with invalid value' do
            specify do
              expect { subject.email_pattern = 'not_regex_object' }
                .to raise_error(Truemail::Configuration::ArgumentError)
            end
          end
        end
      end
    end
  end
end
