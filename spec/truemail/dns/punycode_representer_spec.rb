# frozen_string_literal: true

RSpec.describe Truemail::Dns::PunycodeRepresenter do
  describe '.call' do
    subject(:service) { described_class.call(email) }

    context 'when email is not a string' do
      let(:email) { true }

      specify { expect(service).to be_nil }
    end

    context 'when email not includes ASCII chars' do
      let(:email) { random_email }

      it 'returns not changed email' do
        expect(SimpleIDN).not_to receive(:to_ascii)
        expect(service).to eq(email)
      end
    end

    context 'when email includes ASCII chars' do
      let(:user) { 'niña' }
      let(:domain) { 'mañana.cøm' }
      let(:punycode) { 'xn--maana-pta.xn--cm-lka' }
      let(:email) { "#{user}@#{domain}" }

      it 'returns email with domain represented as punycode' do
        expect(SimpleIDN).to receive(:to_ascii).with(domain.downcase).and_call_original
        expect(service).to eq("#{user}@#{punycode}")
      end
    end
  end
end
