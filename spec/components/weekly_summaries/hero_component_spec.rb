require 'rails_helper'

RSpec.describe WeeklySummaries::HeroComponent, type: :component do
  let(:summary) do
    WeeklySummaries::Builder::Summary.new(
      week:           Calendars::Week.containing(Date.new(2026, 7, 6)),
      profit:         987.40,
      earnings_total: 1_512.40,
      expenses_total: 525.00,
      trips:          32,
      days_worked:    5,
      per_km:         1.31,
      daily_profits:  [300, 0, -150, 0, 600, 0, 0],
      best_day_index: 4,
      goal:           nil,
      top_categories: [],
      empty_days:     [],
      blank_week:     false
    )
  end

  it 'renders profit, trips, worked days and profit per km' do
    html = view_context.render(described_class.new(summary: summary))

    expect(html).to include('R$ 987,40')
    expect(html).to include('32')
    expect(html).to include('5')
    expect(html).to include('R$ 1,31')
  end

  it 'shows earnings and expenses under the profit' do
    page_html = Capybara.string(view_context.render(described_class.new(summary: summary)))

    expect(page_html).to have_css('span.text-emerald-700', text: '+R$ 1.512,40')
    expect(page_html).to have_css('span.text-red-700', text: '−R$ 525,00')
    expect(page_html).to have_text('receitas')
    expect(page_html).to have_text('despesas')
  end

  it 'shows a dash when profit per km is unknown' do
    html = view_context.render(described_class.new(summary: summary.with(per_km: nil)))

    expect(html).to include(I18n.t('weekly_summaries.show.empty_value'))
  end
end
