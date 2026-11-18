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

  it 'renders the light filters button before the type chips without a slice' do
    button = Capybara.string(html).find('button', text: I18n.t('history.index.filters.button'), exact_text: true)

    expect(button[:class]).to include('bg-white border border-slate-200 text-slate-700')
    expect(button['data-action']).to eq('history-filter-panel#open')
  end

  context 'with a slice that marks levels below the type' do
    let(:slice) { History::Slice.new(categories: %w[fuel], vendors: { 'fuel' => ['Posto Orense'] }) }
    let(:page) { Capybara.string(view_context.render(described_class.new(slice: slice, query: 'posto', year: 2026, month: 5))) }

    it 'darkens the filters button with the number of marked items' do
      button = page.find('button', text: I18n.t('history.index.filters.button_count', count: 2))

      expect(button[:class]).to include('bg-slate-800 text-white')
    end

    it 'swaps the type chips for the pills, with a chevron before the vendor pill' do
      expect(page).to have_no_link(I18n.t('history.index.filters.all'))
      expect(page.all('[data-slice-pill]').map(&:text)).to eq(['Combustível', 'Posto Orense'])
      expect(page).to have_css('svg + span[data-slice-pill="vendors"]')
    end

    it 'removes a level from the pill cross, keeping the search and the period' do
      remove = page.find("a[aria-label='#{I18n.t('history.index.trail.remove', label: 'Combustível')}']")

      expect(remove[:href]).to eq(helpers.history_path(types: %w[expenses], q: 'posto', year: 2026, month: 5))
    end

    it 'reopens the panel at the pill level from the pill body' do
      body = page.find('[data-slice-pill="vendors"] button')

      expect(body['data-action']).to eq('history-filter-panel#open')
      expect(body['data-history-filter-panel-level-param']).to eq('vendors')
    end

    it 'offers a desktop link that clears the slice, keeping the search and the period' do
      clear = page.find('a', text: I18n.t('history.index.filters.clear'), exact_text: true)

      expect(clear[:href]).to eq(helpers.history_path(q: 'posto', year: 2026, month: 5))
      expect(clear[:class]).to include('hidden lg:inline')
    end
  end

  it 'ends the desktop chip bar with the mode toggle for a single series with a month' do
    page = Capybara.string(view_context.render(described_class.new(slice: History::Slice.new(categories: %w[insurance]), query: nil, year: 2026, month: 5)))

    expect(page.find('.hidden.lg\:block.ml-auto')).to have_link(I18n.t('history.index.mode.twelve_months'))
  end

  it 'leaves the mode toggle out for a slice of two categories' do
    page = Capybara.string(view_context.render(described_class.new(slice: History::Slice.new(categories: %w[fuel insurance]), query: nil, year: 2026, month: 5)))

    expect(page).to have_no_css('[data-mode-toggle]')
  end
end
