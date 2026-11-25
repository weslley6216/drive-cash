require 'rails_helper'

RSpec.describe Refuelings::CycleResultComponent, type: :component do
  let(:cycle) do
    Refuelings::TankCycles::Cycle.new(opener: { date: Date.new(2026, 6, 7) }, moves: [], closing_balance: BigDecimal('214'),
                                      current: true, km_per_liter: nil)
  end

  it 'shows what remains on the current tank' do
    html = view_context.render(described_class.new(cycle: cycle))

    expect(html).to eq('<span class="text-xs font-semibold text-slate-700 tabular-nums">resta R$ 214,00</span>')
  end

  it 'shows the balance a closed tank ended on' do
    html = view_context.render(described_class.new(cycle: cycle.with(current: false, closing_balance: BigDecimal('149'))))

    expect(html).to eq('<span class="text-xs font-medium text-slate-500 tabular-nums">fechou em R$ 149,00</span>')
  end

  it 'shows in red how far a closed tank went beyond its balance' do
    html = view_context.render(described_class.new(cycle: cycle.with(current: false, closing_balance: BigDecimal('-1'))))

    expect(html).to eq('<span class="text-xs font-semibold text-red-700 tabular-nums">−R$ 1,00 além</span>')
  end
end
