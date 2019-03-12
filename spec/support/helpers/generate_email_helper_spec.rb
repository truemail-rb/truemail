module Truemail
  RSpec.describe GenerateEmailHelper, type: :helper do
    describe '.call' do
      context 'without params' do
        subject(:generate_email) { described_class.call }

        specify { expect(generate_email).to be_an_instance_of(String) }
        specify { 100.times { expect(generate_email.size).to be_between(15, 255) } }
        specify { 100.times { expect(generate_email).to include(*%w[@ - _ .]) } }
      end

      context 'with size: :min' do
        specify { expect(described_class.call(size: :min).size).to eq(6) }
      end

      context 'with size: :max' do
        specify { expect(described_class.call(size: :max).size).to eq(255) }
      end

      context 'with size: :out_of_range' do
        specify { expect(described_class.call(size: :out_of_range).size).to be > 255 }
      end

      context 'when invalid_email_with exists' do
        let(:not_allowed_symbols) { %w[! ~ , ' & %] }

        specify do
          100.times do
            expect(
              described_class.call(invalid_email_with: not_allowed_symbols)
            ).to include(*not_allowed_symbols)
          end
        end

        specify do
          expect(
            described_class.call(size: :min, invalid_email_with: not_allowed_symbols)
          ).to match(/\W/)
        end
      end
    end
  end
end
