require 'rails_helper'

RSpec.describe WeeklySummaries::ShowView, type: :component do
  let(:week) { Calendars::Week.containing(Date.new(2026, 7, 6)) }
  let(:goal) do
    build_stubbed(:goal, kind: 'weekly', metric: 'profit', target_amount: 1_100,
                         period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))
  end
  let(:summary) do
    WeeklySummaries::Builder::Summary.new(
      week:           week,
      profit:         987.40,
      earnings_total: 1_512.40,
      expenses_total: 525.00,
      trips:          32,
      days_worked:    5,
      per_km:         1.31,
      daily_profits:  [300, 0, -150, 0, 600, 0, 0],
      best_day_index: 4,
      goal:           WeeklySummaries::Builder::GoalProgress.new(goal: goal, achieved: 987.40, percent: 89, hit: false),
      top_categories: [WeeklySummaries::Builder::TopCategory.new(key: 'fuel', amount: 312.0)],
      empty_days:     [Date.new(2026, 7, 7)],
      blank_week:     false
    )
  end

  before { travel_to Time.zone.local(2026, 7, 20, 10, 0) }

  def render_view(summary)
    Capybara.string(view_context.render(described_class.new(summary: summary)))
  end

  it 'formats a week inside one month, with the year on the desktop' do
    page_html = render_view(summary)

    expect(page_html).to have_text('6 a 12 de julho')
    expect(page_html).to have_text('6 a 12 de julho de 2026')
  end

  it 'formats a week across two months' do
    page_html = render_view(summary.with(week: Calendars::Week.containing(Date.new(2026, 6, 29))))

    expect(page_html).to have_text('29 de junho a 5 de julho')
  end

  it 'formats a week across two years' do
    page_html = render_view(summary.with(week: Calendars::Week.containing(Date.new(2025, 12, 29))))

    expect(page_html).to have_text('29 de dezembro de 2025 a 4 de janeiro de 2026')
  end

  it 'navigates between weeks from the phone and the desktop headers' do
    page_html = render_view(summary)

    expect(page_html).to have_css("a[aria-label='Semana anterior'][href='/weekly_summaries/2026-06-29']", count: 2)
    expect(page_html).to have_css('a.w-10.h-10', count: 2)
  end

  it 'shows the goal block only with a weekly goal' do
    expect(render_view(summary)).to have_text('Meta da semana')
    expect(render_view(summary.with(goal: nil))).to have_no_text('Meta da semana')
  end

  it 'shows where the money went only with paid expenses' do
    expect(render_view(summary)).to have_text('Onde foi o dinheiro')
    expect(render_view(summary.with(top_categories: []))).to have_no_text('Onde foi o dinheiro')
  end

  it 'links the CTA to the history of the week' do
    expect(render_view(summary)).to have_link('Ver lançamentos da semana', href: '/history?week=2026-07-06', count: 2)
  end

  it 'links the analysis of the month of the monday as a secondary link' do
    page_html = render_view(summary.with(week: Calendars::Week.containing(Date.new(2026, 6, 29))))

    expect(page_html).to have_link('Análise de junho →', href: '/analysis?month=6&year=2026', count: 2)
  end

  it 'links back to the notification center' do
    expect(render_view(summary)).to have_link(href: '/notifications')
  end
end
