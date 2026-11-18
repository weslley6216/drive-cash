require 'rails_helper'

RSpec.describe Records::AmountAndDateComponent, type: :component do
  before { travel_to Time.zone.local(2026, 5, 22, 10, 0) }

  it 'renders the amount input with the stored amount in the theme color' do
    html = view_context.render(described_class.new(amount: 120.5, date: Date.new(2026, 5, 20), theme: :emerald))

    expect(html).to include('name="record[amount]" value="120.5"')
    expect(html).to include('text-emerald-700')
  end

  it 'renders the date input and the short label with the record date' do
    html = view_context.render(described_class.new(amount: nil, date: Date.new(2026, 5, 20), theme: :red))

    expect(html).to include('name="record[date]" value="2026-05-20"')
    expect(html).to include('20 mai 2026')
  end

  it 'labels today and yesterday by name' do
    today = view_context.render(described_class.new(amount: nil, date: Date.new(2026, 5, 22), theme: :red))
    yesterday = view_context.render(described_class.new(amount: nil, date: Date.new(2026, 5, 21), theme: :red))

    expect(today).to include(I18n.t('records.new_view.today'))
    expect(yesterday).to include(I18n.t('common.yesterday'))
  end

  it 'labels an older date with its weekday' do
    html = view_context.render(described_class.new(amount: nil, date: Date.new(2026, 5, 18), theme: :red))

    expect(html).to include('Segunda-feira')
  end

  it 'falls back to today when the record has no date' do
    html = view_context.render(described_class.new(amount: nil, date: nil, theme: :red))

    expect(html).to include('name="record[date]" value="2026-05-22"')
  end
end
