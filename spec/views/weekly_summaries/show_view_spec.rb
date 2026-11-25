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
      days:           week.range.zip([300, 0, -150, 0, 600, 0, 0]).map do |date, profit|
        WeeklySummaries::Builder::Day.new(date: date, profit: profit, earnings: [profit, 0].max, expenses: [-profit, 0].max,
                                          trips: 0, empty: profit.zero?, future: false)
      end,
      best_day_index: 4,
      goal:           WeeklySummaries::Builder::GoalProgress.new(goal: goal, achieved: 987.40, percent: 89, hit: false),
      top_categories: [WeeklySummaries::Builder::TopCategory.new(key: 'fuel', amount: 312.0)],
      empty_days:     [Date.new(2026, 7, 7)],
      blank_week:     false
    )
  end

  before { travel_to Time.zone.local(2026, 7, 20, 10, 0) }

  let(:page_html) { Capybara.string(view_context.render(described_class.new(summary: summary, unread_count: 0))) }

  it 'formats a week inside one month, with the year on the desktop' do
    expect(page_html).to have_text('6 a 12 de julho')
    expect(page_html).to have_text('6 a 12 de julho de 2026')
  end

  it 'formats a week across two months' do
    week = Calendars::Week.containing(Date.new(2026, 6, 29))

    week_page = Capybara.string(view_context.render(described_class.new(summary: summary.with(week: week), unread_count: 0)))

    expect(week_page).to have_text('29 de junho a 5 de julho')
  end

  it 'formats a week across two years' do
    week = Calendars::Week.containing(Date.new(2025, 12, 29))

    week_page = Capybara.string(view_context.render(described_class.new(summary: summary.with(week: week), unread_count: 0)))

    expect(week_page).to have_text('29 de dezembro de 2025 a 4 de janeiro de 2026')
  end

  it 'navigates between weeks from the phone and the desktop headers' do
    expect(page_html).to have_css("a[aria-label='Semana anterior'][href='/weekly_summaries/2026-06-29']", count: 2)
    expect(page_html).to have_css('a.w-10.h-10.rounded-full', count: 2)
  end

  it 'shows the goal block only with a weekly goal' do
    goalless_page = Capybara.string(view_context.render(described_class.new(summary: summary.with(goal: nil), unread_count: 0)))

    expect(page_html).to have_text('Meta da semana')
    expect(goalless_page).to have_no_text('Meta da semana')
  end

  it 'shows where the money went only with paid expenses' do
    unpaid_page = Capybara.string(view_context.render(described_class.new(summary: summary.with(top_categories: []), unread_count: 0)))

    expect(page_html).to have_text('Onde foi o dinheiro')
    expect(unpaid_page).to have_no_text('Onde foi o dinheiro')
  end

  it 'links the CTA to the history of the week' do
    expect(page_html).to have_link('Ver lançamentos da semana', href: '/history?week=2026-07-06', count: 2)
  end

  it 'styles the desktop CTA as the blue topbar button' do
    expect(page_html).to have_css("a.bg-blue-600.rounded-lg[href='/history?week=2026-07-06']")
  end

  it 'puts the week nav and the CTA on the shared topbar before the bell' do
    topbar = page_html.find('header', text: 'Sua semana')

    expect(topbar).to have_css('a.w-10.h-10.rounded-full', count: 2)
    expect(topbar).to have_link('Ver lançamentos da semana', href: '/history?week=2026-07-06')
    expect(topbar).to have_link('Notificações')
  end

  it 'keeps the desktop analysis link inline inside its paragraph' do
    expect(page_html).to have_css("p.hidden a[href='/analysis?month=7&year=2026']", text: 'Análise de julho →')
  end

  it 'links the analysis of the month of the monday as a secondary link' do
    week = Calendars::Week.containing(Date.new(2026, 6, 29))

    week_page = Capybara.string(view_context.render(described_class.new(summary: summary.with(week: week), unread_count: 0)))

    expect(week_page).to have_link('Análise de junho →', href: '/analysis?month=6&year=2026', count: 2)
  end

  it 'links back to the notification center' do
    expect(page_html).to have_link(href: '/notifications')
  end
end
