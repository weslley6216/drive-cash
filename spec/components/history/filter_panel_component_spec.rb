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

  def render_panel(slice: History::Slice.new, query: nil)
    Capybara.string(view_context.render(described_class.new(slice: slice, facets: facets, year: 2026, month: 5, query: query)))
  end

  let(:page) { render_panel }

  it 'starts hidden as the panel target with a GET form to the history' do
    panel = page.find('[data-history-filter-panel-target="panel"]')
    form = panel.find('form')

    expect(panel[:class]).to include('hidden')
    expect(form[:action]).to eq('/history')
    expect(form[:method]).to eq('get')
  end

  it 'keeps the period and the search in hidden fields' do
    hidden = render_panel(query: 'posto').all('input[type="hidden"]', visible: false).map { |input| [input[:name], input[:value]] }

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
    expect(fuel).to have_text('R$ 195')
    expect(fuel[:class]).not_to include('opacity-40')
    expect(toll[:class]).to include('opacity-40')
  end

  it 'lists every platform' do
    expect(page).to have_field('platforms[]', count: Earning.platforms.size)
    expect(page.find('label', text: 'Uber')).to have_text('2')
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
    marked = render_panel(slice: History::Slice.new(categories: %w[fuel], vendors: { 'fuel' => ['Posto Orense'] }, unpaid: '1'))

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
      'one'  => I18n.t('history.index.panel.submit.one'),
      'all'  => I18n.t('history.index.panel.submit_all', count: 6),
      'none' => I18n.t('history.index.panel.submit_none')
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
