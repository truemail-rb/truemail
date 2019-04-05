# frozen_string_literal: true

module Truemail
  RSpec.shared_examples 'request retry behavior' do
    before { error_stubs }

    context 'when attempts not exists' do
      specify do
        expect { response_instance_target_method }.to not_change(request_instance, :attempts)
      end
    end

    context 'when attempts exists' do
      let(:attempts) { { attempts: 5 } }

      specify do
        expect { response_instance_target_method }.to change(request_instance, :attempts).from(5).to(0)
      end
    end
  end
end
