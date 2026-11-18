require 'rails_helper'

RSpec.describe History::SearchBarComponent, type: :component do
  let(:html) { view_context.render(described_class.new(query: nil, slice: History::Slice.new)) }

  it 'renders a search input with the i18n placeholder' do
    expect(html).to include(%(name="q"))
    expect(html).to include(I18n.t('history.index.search_placeholder'))
  end

  it 'renders the current query as the input value' do
    new_html = view_context.render(described_class.new(query: 'posto', slice: History::Slice.new))

    expect(new_html).to include('value="posto"')
  end

  it 'carries the slice in hidden fields so the search stays inside it' do
    slice = History::Slice.new(categories: %w[fuel], unpaid: '1', vendors: { 'fuel' => ['Posto Orense'] })
    form = Capybara.string(view_context.render(described_class.new(query: nil, slice: slice)))
    hidden = form.all('input[type="hidden"]', visible: false).map { |input| [input[:name], input[:value]] }

    expect(hidden).to contain_exactly(%w[types[] expenses], %w[unpaid 1], %w[categories[] fuel], ['vendors[fuel][]', 'Posto Orense'])
  end

  it 'renders no hidden field for an empty slice' do
    expect(Capybara.string(html).all('input[type="hidden"]', visible: false)).to be_empty
  end

  it 'wires the form to the history-search Stimulus controller with debounce action' do
    expect(html).to include('data-controller="history-search"')
    expect(html).to include('history-search#debounce')
  end

  it 'submits as GET to /history' do
    expect(html).to include(%(action="#{Rails.application.routes.url_helpers.history_path}"))
    expect(html).to include('method="get"')
  end

  context 'when query is present' do
    let(:html) { view_context.render(described_class.new(query: 'uber', slice: History::Slice.preset('earnings'))) }

    it 'renders a clear button with accessible label' do
      expect(html).to include(I18n.t('history.index.search_clear'))
    end

    it 'clear button links to history without the search query, preserving the slice' do
      expect(html).to include(%(href="#{Rails.application.routes.url_helpers.history_path(types: %w[earnings])}"))
    end

    it 'clear button has cursor-pointer' do
      expect(html).to include('cursor-pointer')
    end
  end

  context 'when query is blank' do
    it 'does not render a clear button' do
      expect(html).not_to include(I18n.t('history.index.search_clear'))
    end
  end
end
