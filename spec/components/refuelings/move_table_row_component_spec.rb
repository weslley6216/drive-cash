require 'rails_helper'

RSpec.describe Refuelings::MoveTableRowComponent, type: :component do
  it 'lays a consumption out on the desktop grid with the balance after it' do
    move = { kind: :debit, date: Date.new(2026, 6, 4), amount: BigDecimal('-400'), description: 'Rota Mercado Livre',
             balance_after: BigDecimal('-1') }

    row = Nokogiri::HTML5.fragment(view_context.render(described_class.new(move: move))).at_css('div')

    expect(row['class']).to eq('grid grid-cols-[150px_minmax(0,1fr)_110px_120px] gap-4 px-5 py-3 items-center border-b border-slate-100 text-sm')
    expect(row['data-tank-filter-kind']).to eq('route')
    expect(row.element_children.map(&:text)).to eq(['04 jun', 'Rota Mercado LivreCombustível', "−R$\u00A0400,00", "−R$\u00A01,00"])
    expect(row.element_children.last['class']).to eq('text-right tabular-nums text-red-700 font-semibold')
    expect(row.at_css('span.font-medium')['class']).to eq('font-medium text-slate-800 truncate')
  end

  it 'lays a full tank out with its vendor detail and a plain balance' do
    move = { kind: :credit, date: Date.new(2026, 6, 7), amount: BigDecimal('260'), full_tank: true, vendor: 'Posto Orense',
             liters: BigDecimal('44.1'), price_per_liter: BigDecimal('5.89'), balance_after: BigDecimal('259') }

    row = Nokogiri::HTML5.fragment(view_context.render(described_class.new(move: move))).at_css('div')

    expect(row['data-tank-filter-kind']).to eq('fill')
    expect(row.text).to include('Tanque cheio')
    expect(row.text).to include("Posto Orense · 44,1 L · R$\u00A05,89/L")
    expect(row.at_css('span.font-medium')['class']).to eq('font-medium text-slate-800')
    expect(row.element_children[2].text).to eq("+R$\u00A0260,00")
    expect(row.element_children.last['class']).to eq('text-right tabular-nums text-slate-600')
    expect(row.element_children.last.text).to eq("R$\u00A0259,00")
  end
end
