require 'rails_helper'

RSpec.describe Notifications::Preferences do
  it 'treats a missing kind as enabled' do
    preferences = described_class.new({})

    expect(preferences.enabled?('tank_low')).to be(true)
  end

  it 'treats a stored false as disabled' do
    preferences = described_class.new('tank_low' => false)

    expect(preferences.enabled?('tank_low')).to be(false)
  end

  it 'lists the disabled kinds' do
    preferences = described_class.new('tank_low' => false, 'log_reminder' => false)

    expect(preferences.disabled_kinds).to contain_exactly('tank_low', 'log_reminder')
  end

  it 'disables a kind without touching the others' do
    preferences = described_class.new('log_reminder' => false)

    result = preferences.with('tank_low', false)

    expect(result.to_h).to eq('log_reminder' => false, 'tank_low' => false)
  end

  it 're-enables a kind by removing its key' do
    preferences = described_class.new('tank_low' => false)

    result = preferences.with('tank_low', true)

    expect(result.to_h).to eq({})
  end

  it 'is idempotent when enabling an enabled kind' do
    preferences = described_class.new

    result = preferences.with('tank_low', true)

    expect(result.to_h).to eq({})
  end

  it 'is idempotent when disabling a disabled kind' do
    preferences = described_class.new('tank_low' => false)

    result = preferences.with('tank_low', false)

    expect(result.to_h).to eq('tank_low' => false)
  end

  it 'does not freeze the hash it was built from' do
    settings = { 'tank_low' => false }

    described_class.new(settings)

    expect(settings).not_to be_frozen
  end

  it 'normalizes symbol keys to strings' do
    preferences = described_class.new(tank_low: false)

    expect(preferences.enabled?('tank_low')).to be(false)
  end

  it 'returns a new instance without mutating the original' do
    preferences = described_class.new('tank_low' => false)

    preferences.with('tank_low', true)

    expect(preferences.to_h).to eq('tank_low' => false)
  end
end
