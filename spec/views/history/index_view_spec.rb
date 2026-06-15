require 'rails_helper'

RSpec.describe History::IndexView, type: :component do
  let(:summary) { { earnings: 200.0, expenses: 80.0, net: 120.0 } }
  let(:feed) { { groups: [], summary: summary } }
  let(:html) do
    view_context.render(
      described_class.new(
        feed:            feed,
        year:            2025,
        month:           nil,
        query:           nil,
        filter:          'all',
        available_years: [2025]
      )
    )
  end

  it 'pins the header outside the scroll region' do
    expect(html).to include('flex-none')
  end

  it 'creates a scrollable region for the feed' do
    expect(html).to include('overflow-y-auto')
  end

  it 'uses app-shell layout (full-height, no body scroll)' do
    expect(html).to include('h-[100dvh]')
    expect(html).to include('flex flex-col')
  end

  it 'renders the period summary in the pinned header' do
    expect(html).to include(I18n.t('history.index.summary.earnings'))
  end

  it 'renders the search bar in the pinned header' do
    expect(html).to include(I18n.t('history.index.search_placeholder'))
  end

  it 'renders filter chips in the pinned header' do
    expect(html).to include(I18n.t('history.index.filters.all'))
  end

  it 'renders the month/year filter in the pinned header' do
    expect(html).to include('data-controller="filter"')
  end

  it 'shows the empty state inside the scroll region when there are no groups' do
    expect(html).to include(I18n.t('history.index.empty'))
  end

  it 'wraps page content in turbo_frame page so filter updates do not reload nav' do
    expect(html).to include('id="page"')
  end
end
