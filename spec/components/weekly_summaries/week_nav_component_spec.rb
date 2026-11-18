require 'rails_helper'

RSpec.describe WeeklySummaries::WeekNavComponent, type: :component do
  before { travel_to Time.zone.local(2026, 7, 14, 10, 0) }

  def render_nav(week, **options)
    Capybara.string(view_context.render(described_class.new(week: week, **options)))
  end

  it 'links both neighbour weeks of a past week' do
    html = render_nav(Calendars::Week.containing(Date.new(2026, 7, 6)))

    expect(html).to have_css("a[aria-label='Semana anterior'][href='/weekly_summaries/2026-06-29']")
    expect(html).to have_css("a[aria-label='Próxima semana'][href='/weekly_summaries/2026-07-13']")
  end

  it 'disables the next week on the current week' do
    html = render_nav(Calendars::Week.containing(Date.new(2026, 7, 14)))

    expect(html).to have_css("a[aria-label='Semana anterior'][href='/weekly_summaries/2026-07-06']")
    expect(html).to have_css("button[disabled][aria-label='Próxima semana'].text-slate-300")
    expect(html).to have_no_css("a[aria-label='Próxima semana']")
  end

  it 'sizes the buttons as the prototype on the phone and on the desktop' do
    week = Calendars::Week.containing(Date.new(2026, 7, 6))

    expect(render_nav(week)).to have_css('a.w-9.h-9.rounded-full', count: 2)
    expect(render_nav(week, size: 'w-10 h-10')).to have_css('a.w-10.h-10.rounded-full', count: 2)
  end
end
