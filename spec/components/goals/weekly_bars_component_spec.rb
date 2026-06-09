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

  it 'highlights today with dashed blue border' do
    expect(html).to include('border-blue-500')
    expect(html).to include('border-dashed')
  end

  it 'styles future days with slate-100' do
    expect(html).to include('bg-slate-100')
  end

  it 'shows single-letter uppercase abbreviation for mobile' do
    first_letter = I18n.l(Date.new(2026, 6, 8), format: '%a').upcase[0]
    expect(html).to include(first_letter)
  end

  it 'shows 3-letter capitalized abbreviation for desktop' do
    three_letters = I18n.l(Date.new(2026, 6, 8), format: '%a').capitalize.first(3)
    expect(html).to include(three_letters)
  end

  it 'labels today with blue text' do
    expect(html).to include('text-blue-600')
  end
end
