require 'rails_helper'

RSpec.describe History::SearchBarComponent, type: :component do
  let(:html) { view_context.render(described_class.new(query: nil, filter: 'all')) }

  it 'renders a search input with the i18n placeholder' do
    expect(html).to include(%(name="q"))
    expect(html).to include(I18n.t('history.index.search_placeholder'))
  end

  it 'renders the current query as the input value' do
    new_html = view_context.render(described_class.new(query: 'posto', filter: 'all'))

    expect(new_html).to include('value="posto"')
  end

  it 'preserves the current filter via hidden field' do
    new_html = view_context.render(described_class.new(query: nil, filter: 'unpaid'))

    expect(new_html).to include('name="filter"')
    expect(new_html).to include('value="unpaid"')
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
    let(:html) { view_context.render(described_class.new(query: 'uber', filter: 'earnings')) }

    it 'renders a clear button with accessible label' do
      expect(html).to include(I18n.t('history.index.search_clear'))
    end

    it 'clear button links to history without the search query, preserving filter' do
      expect(html).to include(%(href="#{Rails.application.routes.url_helpers.history_path(filter: 'earnings')}"))
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
