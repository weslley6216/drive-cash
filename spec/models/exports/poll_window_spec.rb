require 'rails_helper'

RSpec.describe Exports::PollWindow do
  it 'derives enough attempts to cover the stale window' do
    window = described_class.new(stale_after: 3.minutes, interval_ms: 4_000)

    expect(window.max_attempts).to eq(46)
  end

  it 'keeps polling past the stale window so the row always reaches a terminal state' do
    window = described_class.new(stale_after: 3.minutes, interval_ms: 4_000)

    expect(window.max_attempts * window.interval_ms).to be > 3.minutes.in_milliseconds
  end

  it 'covers the stale window for a longer interval too' do
    window = described_class.new(stale_after: 3.minutes, interval_ms: 10_000)

    expect(window.max_attempts * window.interval_ms).to be > 3.minutes.in_milliseconds
  end

  it 'defaults to the model stale window' do
    window = described_class.new

    expect(window.max_attempts * window.interval_ms).to be > Export::STALE_AFTER.in_milliseconds
  end

  it 'exposes the interval used by the client' do
    expect(described_class.new.interval_ms).to eq(4_000)
  end
end
