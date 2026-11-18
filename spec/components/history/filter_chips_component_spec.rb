require 'rails_helper'

RSpec.describe History::FilterChipsComponent, type: :component do
  let(:helpers) { Rails.application.routes.url_helpers }
  let(:html) { view_context.render(described_class.new(slice: History::Slice.new, query: nil)) }

  it 'renders the four type chips from i18n in order' do
    expect(Capybara.string(html).all('a').map(&:text))
      .to eq(%w[all earnings expenses unpaid].map { |key| I18n.t("history.index.filters.#{key}") })
  end

  it 'links each chip to the history with its preset params' do
    hrefs = Capybara.string(html).all('a').map { |link| link[:href] }

    expect(hrefs).to eq([helpers.history_path, helpers.history_path(types: %w[earnings]),
                         helpers.history_path(types: %w[expenses]), helpers.history_path(types: %w[expenses], unpaid: '1')])
  end

  it 'preserves the search, year and month in the chip links' do
    new_html = view_context.render(described_class.new(slice: History::Slice.new, query: 'posto', year: 2026, month: 5))

    expect(Capybara.string(new_html).find('a', text: I18n.t('history.index.filters.earnings'))[:href])
      .to eq(helpers.history_path(types: %w[earnings], q: 'posto', year: 2026, month: 5))
  end

  it 'omits year and month from chip links when not provided' do
    expect(html).not_to include('year=')
    expect(html).not_to include('month=')
  end

  it 'highlights only the chip of the active preset and marks it for the chip strip' do
    new_html = view_context.render(described_class.new(slice: History::Slice.preset('unpaid'), query: nil))

    active = Capybara.string(new_html).all('a.bg-slate-800.text-white')
    expect(active.map(&:text)).to eq([I18n.t('history.index.filters.unpaid')])
    expect(active.first['data-chip-strip-target']).to eq('active')
  end

  it 'styles inactive chips with white background' do
    expect(html).to include('bg-white')
    expect(html).to include('border-slate-200')
  end

  it 'renders chips in a horizontally scrollable row' do
    expect(html).to include('overflow-x-auto')
  end
end
