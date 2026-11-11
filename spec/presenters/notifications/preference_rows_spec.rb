require 'rails_helper'

RSpec.describe Notifications::PreferenceRows do
  let(:settings) { Notifications::Preferences.new }

  it 'returns one row per registered kind in registry order' do
    rows = described_class.call(settings)

    expect(rows.map(&:kind)).to eq(Notifications::Registry::KINDS)
  end

  it 'uses the kind title and rule' do
    rows = described_class.call(settings)

    row = rows.find { |candidate| candidate.kind == 'log_reminder' }

    expect(row.title).to eq('Lembrete de registrar')
    expect(row.rule).to eq('No máximo 1 por dia, só em dias que você costuma rodar.')
  end

  it 'takes icon and palette from the kind presenter' do
    rows = described_class.call(settings)
    maintenance_due = rows.find { |candidate| candidate.kind == 'maintenance_due' }
    goal_reached = rows.find { |candidate| candidate.kind == 'goal_reached' }

    expect(maintenance_due.icon).to eq(PhlexIcons::Lucide::Wrench)
    expect(maintenance_due.palette_key).to eq(:danger)
    expect(goal_reached.palette_key).to eq(:success)
  end

  it 'flags a disabled kind' do
    disabled_settings = Notifications::Preferences.new('log_reminder' => false)

    row = described_class.call(disabled_settings).find { |candidate| candidate.kind == 'log_reminder' }

    expect(row.enabled).to be(false)
  end

  it 'flags an enabled kind' do
    row = described_class.call(settings).find { |candidate| candidate.kind == 'log_reminder' }

    expect(row.enabled).to be(true)
  end
end
