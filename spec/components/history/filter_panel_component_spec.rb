require 'rails_helper'

RSpec.describe History::FilterPanelComponent, type: :component do
  let(:facets) do
    {
      earnings_count: 2,
      expenses_count: 4,
      platforms:      { 'uber' => { count: 2, total: 50.5 } },
      categories:     { 'fuel' => { count: 3, total: 195 }, 'car_wash' => { count: 1, total: 35 } },
      vendors:        {
        'fuel'     => [{ vendor: 'Posto Orense', count: 2, total: 125 }, { vendor: 'Shell', count: 1, total: 70 }],
        'car_wash' => [{ vendor: History::Slice::NO_VENDOR, count: 1, total: 35 }]
      },
      rows:           [{ type: 'earnings', platform: 'uber', count: 2 }]
    }
  end

  let(:page) { Capybara.string(view_context.render(described_class.new(slice: History::Slice.new, facets: facets, year: 2026, month: 5,
                                                                       query: nil))) }

  it 'starts hidden as the panel target with a GET form to the history' do
    panel = page.find('[data-history-filter-panel-target="panel"]')
    form = panel.find('form')

    expect(panel[:class]).to include('hidden')
    expect(form[:action]).to eq('/history')
    expect(form[:method]).to eq('get')
  end

  it 'keeps the period and the search in hidden fields' do
    html = view_context.render(described_class.new(slice: History::Slice.new, facets: facets, year: 2026, month: 5, query: 'posto'))

    hidden = Capybara.string(html).all('input[type="hidden"]', visible: false).map { |input| [input[:name], input[:value]] }

    expect(hidden).to contain_exactly(%w[year 2026], %w[month 5], %w[q posto])
  end

  it 'offers both types with their period counts and the unpaid switch' do
    expect(page).to have_field('types[]', with: 'earnings')
    expect(page).to have_field('types[]', with: 'expenses')
    expect(page).to have_field('unpaid', with: '1')
    expect(page.find('label', text: I18n.t('history.index.panel.earnings'))).to have_text('2')
  end

  it 'lists every category with its count and short total, dimming the ones without records' do
    fuel = page.find('label', text: 'Combustível')
    toll = page.find('label', text: 'Pedágio')

    expect(page).to have_field('categories[]', count: Expense.categories.size)
    expect(fuel).to have_text("R$\u00A0195")
    expect(fuel[:class]).not_to include('opacity-40')
    expect(toll[:class]).to include('opacity-40')
  end

  it 'lists every platform' do
    expect(page).to have_field('platforms[]', count: Earning.platforms.size)
    expect(page.find('label', text: 'Uber')).to have_text('2')
  end

  it 'lists the categories in the vehicle then personal order of the prototype' do
    expect(page.all('input[name="categories[]"]', visible: :all).map(&:value)).to eq(Expense::CATEGORIES_BY_GROUP.values.flatten)
  end

  it 'lists the busiest platforms first, then the rest in the enum order' do
    expect(page.all('input[name="platforms[]"]', visible: :all).map(&:value)).to eq(%w[uber amazon ifood mercado_livre nine_nine rappi shopee other])
  end

  it 'counts zero on the rows without records' do
    expect(page.find('label', text: 'Pedágio').find('[data-row-count]').text).to eq('0')
    expect(page.find('label', text: 'Combustível').find('[data-row-count]').text).to eq('3')
  end

  it 'keeps the short total of categories to the phone and shows the vendor one on every screen' do
    fuel_total = page.find('label', text: 'Combustível').find('[data-row-total]')
    vendor_total = page.find('[data-category="fuel"] label', text: 'Posto Orense').find('[data-row-total]')

    expect(fuel_total[:class]).to include('lg:hidden')
    expect(vendor_total[:class]).not_to include('lg:hidden')
    expect(vendor_total).to have_text("R$\u00A0125")
  end

  it 'labels each checkbox for the collapsed group summaries' do
    expect(page.find('input[name="categories[]"][value="fuel"]', visible: :all)['data-label']).to eq('Combustível')
    expect(page.find('input[value="__none__"]', visible: :all)['data-label']).to eq(I18n.t('history.index.panel.no_vendor'))
  end

  it 'groups the vendors by category, labelling the vendorless ones' do
    fuel = page.find('[data-history-filter-panel-target="vendorBlock"][data-category="fuel"]')
    wash = page.find('[data-history-filter-panel-target="vendorBlock"][data-category="car_wash"]')

    expect(fuel.all('input').map(&:value)).to eq(['Posto Orense', 'Shell'])
    expect(fuel.all('input').map { |input| input[:name] }.uniq).to eq(['vendors[fuel][]'])
    expect(wash).to have_text(I18n.t('history.index.panel.no_vendor'))
    expect(wash.find('input').value).to eq(History::Slice::NO_VENDOR)
  end

  it 'checks what the current slice marks' do
    slice = History::Slice.new(categories: %w[fuel], vendors: { 'fuel' => ['Posto Orense'] }, unpaid: '1')

    marked = Capybara.string(view_context.render(described_class.new(slice: slice, facets: facets, year: 2026, month: 5, query: nil)))

    expect(marked).to have_checked_field('types[]', with: 'expenses')
    expect(marked).to have_checked_field('unpaid')
    expect(marked).to have_checked_field('categories[]', with: 'fuel')
    expect(marked).to have_checked_field('vendors[fuel][]', with: 'Posto Orense')
    expect(marked).to have_unchecked_field('vendors[fuel][]', with: 'Shell')
  end

  it 'wires the vendor search to filter the vendor rows' do
    search = page.find('[data-history-filter-panel-target="vendorSearch"]')

    expect(search).to have_field(placeholder: I18n.t('history.index.panel.vendor_search'))
    expect(search.find('input')['data-action']).to eq('input->history-filter-panel#filterVendors')
  end

  it 'feeds the live count with the facet rows and the footer labels' do
    form = page.find('form')

    expect(JSON.parse(form['data-facets'])).to eq([{ 'type' => 'earnings', 'platform' => 'uber', 'count' => 2 }])
    expect(JSON.parse(form['data-labels'])).to include(
      'one'            => I18n.t('history.index.panel.submit.one'),
      'all'            => I18n.t('history.index.panel.submit_all', count: 6),
      'none'           => I18n.t('history.index.panel.submit_none'),
      'vendors_all'    => I18n.t('history.index.panel.vendors_all'),
      'vendors_marked' => { 'one' => '%{count} marcado', 'other' => '%{count} marcados' },
      'all_feminine'   => 'todas',
      'connectors'     => { 'words' => ', ', 'last_word' => ' e ', 'two_words' => ' e ' }
    )
  end

  it 'closes from the cross and from the backdrop, and clears without submitting' do
    expect(page.find("button[aria-label='#{I18n.t('history.index.panel.close')}']")['data-action']).to eq('history-filter-panel#close')
    expect(page.find('[data-history-filter-panel-target="backdrop"]')['data-action']).to eq('click->history-filter-panel#close')
    expect(page.find('button', text: I18n.t('history.index.panel.clear'), exact_text: true)[:type]).to eq('button')
  end

  it 'labels the submit with the whole period when nothing is marked' do
    expect(page).to have_button(I18n.t('history.index.panel.submit_all', count: 6))
  end
end
