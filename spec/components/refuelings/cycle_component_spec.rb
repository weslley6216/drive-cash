require 'rails_helper'

RSpec.describe Refuelings::CycleComponent, type: :component do
  let(:opener) do
    { kind: :credit, date: Date.new(2026, 5, 28), amount: BigDecimal('250'), full_tank: true, odometer_km: 10_483,
      liters: BigDecimal('42'), vendor: 'Posto Geladão', price_per_liter: BigDecimal('5.95'), balance_after: BigDecimal('399') }
  end
  let(:cycle) do
    Refuelings::TankCycles::Cycle.new(
      opener:          opener,
      moves:           [{ kind: :debit, date: Date.new(2026, 6, 4), amount: BigDecimal('-400'), description: 'Rota Mercado Livre',
                          balance_after: BigDecimal('-1') }, opener],
      closing_balance: BigDecimal('-1'),
      current:         false,
      km_per_liter:    BigDecimal('10.589')
    )
  end
  let(:html) { view_context.render(described_class.new(cycle: cycle)) }

  it 'heads the cycle with the tank date, the km per liter and the result like the prototype' do
    header = Nokogiri::HTML5.fragment(html).at_css('#tank_cycle_2026-05-28 > div:first-child')

    expect(header['class']).to eq('flex items-center justify-between mb-2 px-1 gap-2')
    expect(header.at_css('h3').text).to eq('Tanque de 28 mai')
    expect(header.at_css('h3')['class']).to eq('text-sm font-semibold text-slate-700 truncate')
    expect(header.at_css('span.text-xs.text-slate-400.whitespace-nowrap').text).to eq('10,6 km/L')
    expect(header.text).to include("−R$\u00A01,00 além")
  end

  it 'marks only the current cycle with the Atual chip' do
    current = view_context.render(described_class.new(cycle: cycle.with(current: true, km_per_liter: nil)))

    expect(current).to include('<span class="text-[10px] font-bold uppercase tracking-wide rounded-full px-2 py-0.5 border ' \
                               'text-blue-700 bg-blue-50 border-blue-200">Atual</span>')
    expect(html).not_to include('>Atual<')
  end

  it 'lists the moves of the cycle newest first inside a filterable card' do
    card = Nokogiri::HTML5.fragment(html).at_css('[data-tank-filter-target="card"]')

    expect(card['class']).to eq('bg-white rounded-xl shadow-sm border border-slate-100')
    expect(card.css('[data-tank-filter-target="row"]').map { |row| row['data-tank-filter-kind'] }).to eq(%w[route fill])
    expect(card.text).to include('Rota Mercado Livre')
  end
end
