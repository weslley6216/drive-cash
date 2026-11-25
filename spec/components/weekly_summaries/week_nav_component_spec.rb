require 'rails_helper'

RSpec.describe WeeklySummaries::WeekNavComponent, type: :component do
  before { travel_to Time.zone.local(2026, 7, 14, 10, 0) }

  it 'links both neighbour weeks of a past week' do
    html = Capybara.string(view_context.render(described_class.new(week: Calendars::Week.containing(Date.new(2026, 7, 6)))))

    expect(html).to have_css("a[aria-label='Semana anterior'][href='/weekly_summaries/2026-06-29']")
    expect(html).to have_css("a[aria-label='Próxima semana'][href='/weekly_summaries/2026-07-13']")
  end

  it 'carries the return path to both neighbour weeks' do
    week = Calendars::Week.containing(Date.new(2026, 7, 6))

    html = Capybara.string(view_context.render(described_class.new(week: week, return_to: '/analysis?month=7&year=2026')))

    expect(html).to have_css("a[aria-label='Semana anterior'][href='/weekly_summaries/2026-06-29?return_to=%2Fanalysis%3Fmonth%3D7%26year%3D2026']")
    expect(html).to have_css("a[aria-label='Próxima semana'][href='/weekly_summaries/2026-07-13?return_to=%2Fanalysis%3Fmonth%3D7%26year%3D2026']")
  end

  it 'disables the next week on the current week' do
    html = Capybara.string(view_context.render(described_class.new(week: Calendars::Week.containing(Date.new(2026, 7, 14)))))

    expect(html).to have_css("a[aria-label='Semana anterior'][href='/weekly_summaries/2026-07-06']")
    expect(html).to have_css("button[disabled][aria-label='Próxima semana'].text-slate-300")
    expect(html).to have_no_css("a[aria-label='Próxima semana']")
  end

  it 'sizes the buttons as the prototype on the phone and on the desktop' do
    week = Calendars::Week.containing(Date.new(2026, 7, 6))

    expect(Capybara.string(view_context.render(described_class.new(week: week)))).to have_css('a.w-9.h-9.rounded-full', count: 2)
    expect(Capybara.string(view_context.render(described_class.new(week: week, size: 'w-10 h-10')))).to have_css('a.w-10.h-10.rounded-full',
                                                                                                                 count: 2)
  end
end
