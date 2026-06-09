require 'rails_helper'

RSpec.describe Goals::WeeklyBarsComponent, type: :component do
  let(:days) do
    (Date.new(2026, 6, 8)..Date.new(2026, 6, 14)).map.with_index do |day, index|
      { date: day, value: 100 * (index + 1), done: index < 2, today: index == 2 }
    end
  end
  let(:html) { view_context.render(described_class.new(days: days, target: 1400)) }

  it 'renders 7 bars' do
    expect(html.scan('data-day-bar').size).to eq(7)
  end

  it 'highlights the done days with emerald-500' do
    expect(html).to include('bg-emerald-500')
  end

  it 'highlights today with blue-600' do
    expect(html).to include('bg-blue-600')
  end

  it 'styles future days with slate-200' do
    expect(html).to include('bg-slate-200')
  end

  it 'shows the day abbreviation below each bar' do
    expect(html).to include(I18n.l(Date.new(2026, 6, 8), format: '%a').downcase[0, 3])
  end
end
