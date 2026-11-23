require 'rails_helper'

RSpec.describe WeeklySummaries::GoalComponent, type: :component do
  let(:goal) do
    build_stubbed(:goal, kind: 'weekly', metric: 'profit', target_amount: 1_100,
                         period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))
  end
  let(:progress) { WeeklySummaries::Builder::GoalProgress.new(goal: goal, achieved: 987.40, percent: 89, hit: false) }

  it 'shows how far a missed goal got in amber' do
    html = Capybara.string(view_context.render(described_class.new(progress: progress)))

    expect(html).to have_text('Meta da semana')
    expect(html).to have_text('R$ 987,40 de R$ 1.100,00')
    expect(html).to have_css('span.text-amber-700', text: '89%')
    expect(html).to have_css('.bg-amber-500[style="width: 89%"]')
  end

  it 'shows a reached goal in emerald with the bar capped at the full width' do
    html = Capybara.string(view_context.render(described_class.new(progress: progress.with(achieved: 1_177, percent: 107, hit: true))))

    expect(html).to have_css('span.text-emerald-700', text: '107%')
    expect(html).to have_css('.bg-emerald-500[style="width: 100%"]')
  end

  it 'links to the outcome of the goal' do
    html = Capybara.string(view_context.render(described_class.new(progress: progress)))

    expect(html).to have_link('Ver resultado da meta', href: "/goals/#{goal.id}/outcomes/2026-07-06")
  end
end
