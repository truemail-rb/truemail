# frozen_string_literal: true

RSpec.describe Truemail::Validate::Smtp::Response do
  subject(:response_instance) { described_class.new }

  specify do
    expect(response_instance.members).to include(*Truemail::Validate::Smtp::RESPONSE_ATTRS)
  end

  it 'has default value for errors' do
    expect(response_instance.errors).to eq({})
  end

  it 'accepts parametrized arguments' do
    expect(described_class.new(port_opened: true).port_opened).to be(true)
  end
end
