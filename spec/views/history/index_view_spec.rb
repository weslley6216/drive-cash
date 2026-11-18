require 'rails_helper'

RSpec.describe History::IndexView, type: :component do
  let(:summary) { { earnings: 200.0, expenses: 80.0, net: 120.0 } }
  let(:facets) { { earnings_count: 0, expenses_count: 0, platforms: {}, categories: {}, vendors: {}, rows: [] } }
  let(:feed) { { groups: [], summary: summary, total_count: 0, next_page: nil, facets: facets } }
  let(:html) do
    view_context.render(
      described_class.new(
        feed:    feed,
        year:    2025,
        month:   nil,
        query:   nil,
        slice:   History::Slice.new,
        periods: { 2025 => [3] }
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

  it 'scopes the filters button and the panel to one filter panel controller' do
    toolbar = Capybara.string(html).find('[data-controller~="history-filter-panel"]')

    expect(toolbar).to have_button(I18n.t('history.index.filters.button'))
    expect(toolbar).to have_css('[data-history-filter-panel-target="panel"]')
  end

  it 'renders the month/year filter in the pinned header' do
    expect(html).to include('data-controller="filter-popover"')
  end

  it 'offers a new record from the desktop topbar' do
    expect(html).to include(I18n.t('history.index.new_record'))
  end

  it 'counts the records of the period in the desktop subtitle' do
    html = view_context.render(described_class.new(feed: feed.merge(total_count: 10), year: 2026, month: 5, query: nil, slice: History::Slice.new, periods: { 2026 => [5] }))

    expect(html).to include('10 lançamentos · maio 2026')
  end

  it 'counts against the whole year when no month is picked' do
    html = view_context.render(described_class.new(feed: feed.merge(total_count: 1), year: 2025, month: nil, query: nil, slice: History::Slice.new, periods: { 2025 => [3] }))

    expect(html).to include('1 lançamento · 2025')
  end

  it 'shows the empty state inside the scroll region when there are no groups' do
    expect(html).to include(I18n.t('empty_states.history.blank.title'))
  end

  it 'wraps page content in turbo_frame page so filter updates do not reload nav' do
    expect(html).to include('id="page"')
  end

  context 'with a feed that has more pages' do
    let(:earning) { build_stubbed(:earning, date: Date.new(2026, 5, 22), amount: 50, platform: 'uber') }
    let(:group) { { date: earning.date, items: [earning], earnings_total: 50, expenses_total: 0 } }

    def render_page(next_page:)
      view_context.render(described_class.new(feed: feed.merge(groups: [group], total_count: 2, next_page: next_page),
                                              year: 2026, month: 5, query: nil, slice: History::Slice.new, periods: { 2026 => [5] }))
    end

    it 'puts the load more link inside the feed frame pointing at the next page' do
      link = Capybara.string(render_page(next_page: 2)).find('turbo-frame#history-feed a', text: I18n.t('history.index.load_more'))

      expect(link[:href]).to eq('/history?month=5&page=2&year=2026')
    end

    it 'leaves the load more link out on the last page' do
      expect(render_page(next_page: nil)).not_to include(I18n.t('history.index.load_more'))
    end

    it 'carries the slice in the load more link' do
      html = view_context.render(described_class.new(feed: feed.merge(groups: [group], total_count: 2, next_page: 2),
                                                     year: 2026, month: 5, query: nil, slice: History::Slice.new(categories: %w[fuel]),
                                                     periods: { 2026 => [5] }))
      link = Capybara.string(html).find('turbo-frame#history-feed a', text: I18n.t('history.index.load_more'))

      expect(link[:href]).to eq(Rails.application.routes.url_helpers.history_path(types: %w[expenses], categories: %w[fuel], year: 2026, month: 5, page: 2))
    end
  end

  context 'when a search finds nothing' do
    def render_with(query:, slice:)
      view_context.render(described_class.new(feed: feed, year: 2025, month: nil, query: query, slice: slice, periods: { 2025 => [3] }))
    end

    it 'echoes the search term' do
      expect(render_with(query: 'posto ipiranga', slice: History::Slice.new))
        .to include(CGI.escapeHTML(I18n.t('empty_states.history.description_query', query: 'posto ipiranga')))
    end

    it 'echoes the search term and the active preset' do
      expected = I18n.t('empty_states.history.description_query_filter', query: 'posto', filter: I18n.t('history.index.filters.expenses'))

      expect(render_with(query: 'posto', slice: History::Slice.preset('expenses'))).to include(CGI.escapeHTML(expected))
    end

    it 'hides the period summary' do
      expect(render_with(query: 'posto', slice: History::Slice.new)).not_to include(I18n.t('history.index.summary.net'))
    end

    it 'echoes the search term and the slice sentence' do
      slice = History::Slice.new(categories: %w[fuel], vendors: { 'fuel' => ['Posto Orense'] })
      expected = I18n.t('empty_states.history.description_query_filter', query: 'posto', filter: 'Combustível (Posto Orense)')

      expect(render_with(query: 'posto', slice: slice)).to include(CGI.escapeHTML(expected))
    end

    it 'keeps the generic message when only a preset is active' do
      expect(render_with(query: nil, slice: History::Slice.preset('unpaid'))).to include(I18n.t('empty_states.history.description'))
    end
  end
end
