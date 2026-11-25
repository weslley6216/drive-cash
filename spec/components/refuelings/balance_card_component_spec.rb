require 'rails_helper'

RSpec.describe Refuelings::BalanceCardComponent, type: :component do
  let(:component) { described_class.new(balance: BigDecimal('65'), full: BigDecimal('260'), since: Date.new(2026, 6, 7)) }

  it 'shows the current balance against the last full tank on the phone card' do
    html = Capybara.string(view_context.render(component))

    expect(html).to have_css('div.bg-white.rounded-xl.shadow-sm.border.border-slate-100.p-4')
    expect(html).to have_css('p.text-2xl.font-bold.text-orange-700', text: 'R$ 65,00')
    expect(html).to have_text('de R$ 260,00')
    expect(html).to have_text('desde 07 jun')
    expect(html).to have_css('div.h-1\.5 div.bg-orange-500[style="width: 25%"]')
  end

  it 'shows a larger balance with the tank date on the desktop card' do
    html = Capybara.string(view_context.render(described_class.new(balance: BigDecimal('65'), full: BigDecimal('260'),
                                                                   since: Date.new(2026, 6, 7), variant: :desktop)))

    expect(html).to have_css('div.bg-white.rounded-xl.border.border-slate-200.p-5')
    expect(html).to have_css('p.text-4xl', text: 'R$ 65,00')
    expect(html).to have_text('de R$ 260,00 · tanque de 07 jun')
    expect(html).to have_css('div.h-2 div.bg-orange-500[style="width: 25%"]')
  end

  it 'shows a negative balance in red with an empty bar' do
    html = Capybara.string(view_context.render(described_class.new(balance: BigDecimal('-12'), full: BigDecimal('260'),
                                                                   since: Date.new(2026, 6, 7))))

    expect(html).to have_css('p.text-red-700', text: '−R$ 12,00')
    expect(html).to have_css('div.bg-red-500[style="width: 0%"]')
  end
end
