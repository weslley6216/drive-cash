require 'rails_helper'

RSpec.describe History::DayGroupComponent, type: :component do
  let(:context) { { year: 2025, month: nil, q: nil, filter: 'all' } }
  let(:earning) { create(:earning, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber', trips_count: 3) }
  let(:expense) { create(:expense, date: Date.new(2025, 6, 12), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true) }

  let(:group) do
    {
      date: Date.new(2025, 6, 12),
      items: [earning, expense],
      earnings_total: 200,
      expenses_total: 80
    }
  end

  let(:html) { view_context.render(described_class.new(group: group, context: context)) }

  it 'renders the day totals with + and − signs' do
    expect(html).to include('+ R$')
    expect(html).to include('200,00')
    expect(html).to include('− R$')
    expect(html).to include('80,00')
  end

  it 'colors earnings total in emerald and expenses in red' do
    expect(html).to include('text-emerald-700')
    expect(html).to include('text-red-700')
  end

  it 'labels today as Hoje' do
    today_group = group.merge(date: Date.current)
    today_html = view_context.render(described_class.new(group: today_group, context: context))

    expect(today_html).to include(I18n.t('common.today'))
  end

  it 'labels yesterday as Ontem' do
    yesterday_group = group.merge(date: Date.current - 1)
    yesterday_html = view_context.render(described_class.new(group: yesterday_group, context: context))

    expect(yesterday_html).to include(I18n.t('common.yesterday'))
  end

  it 'falls back to localized short date' do
    expect(html).to include(I18n.l(Date.new(2025, 6, 12), format: :short))
  end

  it 'renders one EntryRow per item' do
    expect(html).to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
    expect(html).to include(I18n.t('activerecord.attributes.expense.categories.fuel'))
  end

  it 'tags the section with a stable id from the date for Turbo Stream targets' do
    expect(html).to include('id="day-2025-06-12"')
  end

  it 'omits the expenses total when zero' do
    earnings_only = group.merge(items: [earning], expenses_total: 0)
    earnings_only_html = view_context.render(described_class.new(group: earnings_only, context: context))

    expect(earnings_only_html).to include('+ R$')
    expect(earnings_only_html).not_to include('− R$')
  end

  it 'omits the earnings total when zero' do
    expenses_only = group.merge(items: [expense], earnings_total: 0)
    expenses_only_html = view_context.render(described_class.new(group: expenses_only, context: context))

    expect(expenses_only_html).to include('− R$')
    expect(expenses_only_html).not_to include('+ R$')
  end
end
