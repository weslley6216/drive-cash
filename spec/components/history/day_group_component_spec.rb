require 'rails_helper'

RSpec.describe History::DayGroupComponent, type: :component do
  let(:context) { { year: 2025, month: nil, q: nil, filter: 'all' } }
  let(:earning) { create(:earning, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber', trips_count: 3) }
  let(:expense) { create(:expense, date: Date.new(2025, 6, 12), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true) }

  let(:group) do
    {
      date:           Date.new(2025, 6, 12),
      items:          [earning, expense],
      earnings_total: 200,
      expenses_total: 80
    }
  end

  let(:html) { view_context.render(described_class.new(group: group, context: context)) }

  it 'renders the rounded day totals with + and − signs and a separator' do
    expect(html).to include('+R$ 200<')
    expect(html).to include('−R$ 80<')
    expect(html).to include('text-slate-300 mx-1.5')
  end

  it 'colors earnings total in emerald and expenses in red' do
    expect(html).to include('text-emerald-700')
    expect(html).to include('text-red-700')
  end

  it 'labels today as Hoje' do
    today_group = group.merge(date: Date.current)
    today_html = view_context.render(described_class.new(group: today_group, context: context))

    expect(today_html).to include("#{I18n.t('common.today')} · #{I18n.l(Date.current, format: '%-d %b')}")
  end

  it 'labels yesterday as Ontem' do
    yesterday_group = group.merge(date: Date.current - 1)
    yesterday_html = view_context.render(described_class.new(group: yesterday_group, context: context))

    expect(yesterday_html).to include("#{I18n.t('common.yesterday')} · #{I18n.l(Date.current - 1, format: '%-d %b')}")
  end

  it 'labels older days with the day, month and weekday' do
    expect(html).to include('12 jun · quinta')
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

    expect(earnings_only_html).to include('+R$')
    expect(earnings_only_html).not_to include('−R$')
  end

  it 'omits the earnings total when zero' do
    expenses_only = group.merge(items: [expense], earnings_total: 0)
    expenses_only_html = view_context.render(described_class.new(group: expenses_only, context: context))

    expect(expenses_only_html).to include('−R$')
    expect(expenses_only_html).not_to include('+R$')
  end
end
