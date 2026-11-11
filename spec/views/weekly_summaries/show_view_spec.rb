require 'rails_helper'

RSpec.describe WeeklySummaries::ShowView, type: :component do
  let(:week) { Date.new(2026, 7, 6)..Date.new(2026, 7, 12) }
  let(:top_category) { WeeklySummaries::Builder::TopCategory.new(key: 'fuel', amount: 312.0) }
  let(:summary) do
    WeeklySummaries::Builder::Summary.new(
      week:           week,
      profit:         987.40,
      trips:          32,
      days_worked:    5,
      per_km:         1.31,
      daily_profits:  [300, 0, -150, 0, 600, 0, 0],
      best_day_index: 4,
      top_category:   top_category
    )
  end

  it 'renders profit, trips, worked days and profit per km' do
    html = view_context.render(described_class.new(summary: summary))

    expect(html).to include('R$ 987,40')
    expect(html).to include('32')
    expect(html).to include('5')
    expect(html).to include('R$ 1,31')
  end

  it 'shows a dash when profit per km is unknown' do
    html = view_context.render(described_class.new(summary: summary.with(per_km: nil)))

    expect(html).to include(I18n.t('weekly_summaries.show.empty_value'))
  end

  it 'formats a week inside one month' do
    html = view_context.render(described_class.new(summary: summary))

    expect(html).to include('6 a 12 de julho')
  end

  it 'formats a week across two months' do
    cross_month_summary = summary.with(week: Date.new(2026, 6, 29)..Date.new(2026, 7, 5))

    html = view_context.render(described_class.new(summary: cross_month_summary))

    expect(html).to include('29 de junho a 5 de julho')
  end

  it 'formats a week across two years' do
    cross_year_summary = summary.with(week: Date.new(2025, 12, 29)..Date.new(2026, 1, 4))

    html = view_context.render(described_class.new(summary: cross_year_summary))

    expect(html).to include('29 de dezembro de 2025 a 4 de janeiro de 2026')
  end

  it 'shows the biggest expense with its category' do
    html = view_context.render(described_class.new(summary: summary))

    expect(html).to include(I18n.t('weekly_summaries.show.top_expense'))
    expect(html).to include(I18n.t('activerecord.attributes.expense.categories.fuel'))
    expect(html).to include('R$ 312,00')
  end

  it 'omits the biggest expense card without paid expenses' do
    html = view_context.render(described_class.new(summary: summary.with(top_category: nil)))

    expect(html).not_to include(I18n.t('weekly_summaries.show.top_expense'))
  end

  it 'links the CTA to the analysis of the week month' do
    cross_month_summary = summary.with(week: Date.new(2026, 6, 29)..Date.new(2026, 7, 5))

    html = view_context.render(described_class.new(summary: cross_month_summary))

    expect(html).to include('href="/analysis?month=6&amp;year=2026"')
  end

  it 'links back to the notification center' do
    html = view_context.render(described_class.new(summary: summary))

    expect(html).to include('href="/notifications"')
  end
end
