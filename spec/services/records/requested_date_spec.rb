require 'rails_helper'

RSpec.describe Records::RequestedDate do
  let(:today) { Date.new(2026, 7, 14) }

  it 'returns the requested date when it is valid and not in the future' do
    result = described_class.call('2026-07-13', today: today)

    expect(result).to eq(Date.new(2026, 7, 13))
  end

  it 'accepts today itself' do
    result = described_class.call('2026-07-14', today: today)

    expect(result).to eq(today)
  end

  it 'falls back to today when the requested date is in the future' do
    result = described_class.call('2026-07-15', today: today)

    expect(result).to eq(today)
  end

  it 'falls back to today when the requested date is garbage' do
    result = described_class.call('lixo', today: today)

    expect(result).to eq(today)
  end

  it 'falls back to today when the requested date is nil' do
    result = described_class.call(nil, today: today)

    expect(result).to eq(today)
  end
end
