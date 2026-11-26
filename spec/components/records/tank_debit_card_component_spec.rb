require 'rails_helper'

RSpec.describe Records::TankDebitCardComponent, type: :component do
  hidden_card = /class="[^"]*\bhidden\b[^"]*"[^>]*data-record-form-target="tankDebit"/

  it 'shows the tank balance before and after the expense amount' do
    html = view_context.render(described_class.new(balance: BigDecimal('260'), expense: Expense.new(category: 'fuel', amount: 80)))

    expect(html).to include(I18n.t('records.new_view.tank_debit.title'))
    expect(html).to include("R$\u00A0260,00")
    expect(html).to include("<span data-record-form-target=\"tankAfter\">R$\u00A0180,00</span>")
  end

  it 'keeps the after balance equal to the current balance without an amount' do
    html = view_context.render(described_class.new(balance: BigDecimal('260'), expense: Expense.new(category: 'fuel')))

    expect(html).to include("<span data-record-form-target=\"tankAfter\">R$\u00A0260,00</span>")
  end

  it 'starts visible for a fuel expense' do
    html = view_context.render(described_class.new(balance: BigDecimal('260'), expense: Expense.new(category: 'fuel')))

    expect(html).to include('data-record-form-target="tankDebit"')
    expect(html).not_to match(hidden_card)
  end

  it 'starts hidden for an expense of another category' do
    html = view_context.render(described_class.new(balance: BigDecimal('260'), expense: Expense.new(category: 'maintenance')))

    expect(html).to match(hidden_card)
  end
end
