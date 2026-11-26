require 'rails_helper'

RSpec.describe History::MonthRowsComponent, type: :component do
  let(:bill) { build_stubbed(:expense, date: Date.new(2026, 5, 10), amount: 214.3, category: 'insurance', vendor: 'Porto Seguro') }
  let(:rows) do
    [
      { year: 2026, month: 5, total: 214.3, count: 1, previous_month: 4, change: 0.0, equal: true, shift: false, record: bill },
      { year: 2026, month: 1, total: 214.3, count: 2, previous_month: 12, change: 12.8, equal: false, shift: true, record: bill },
      { year: 2025, month: 12, total: 189.9, count: 1, previous_month: 11, change: -3.1, equal: false, shift: false, record: bill },
      { year: 2025, month: 6, total: 189.9, count: 1, previous_month: nil, change: nil, equal: false, shift: false, record: bill }
    ]
  end
  let(:slice) { History::Slice.new(categories: %w[insurance], range: '12m') }
  let(:page) { Capybara.string(view_context.render(described_class.new(rows: rows, slice: slice, query: 'porto'))) }
  let(:phone_rows) { page.all('[data-month-row="phone"]') }

  it 'names each month with the year and shows the debit in red on phones' do
    expect(phone_rows.size).to eq(4)
    expect(phone_rows.first).to have_text('Maio 2026')
    expect(phone_rows.first.find('[data-month-amount]').text).to eq("−R$\u00A0214,30")
    expect(phone_rows.first.find('[data-month-amount]')[:class]).to include('text-red-700')
  end

  it 'describes a month of one record like its day row and a busier month by its count' do
    expect(phone_rows.first).to have_text('Porto Seguro')
    expect(phone_rows[1]).to have_text('2 lançamentos')
  end

  it 'compares each month with the previous logged one, the raise in amber' do
    variations = page.all('[data-month-row="phone"] [data-month-variation]')

    expect(variations.map(&:text)).to eq(['= abr', '+12,8% vs dez', '−3,1% vs nov'])
    expect(variations[1][:class]).to include('text-amber-700')
    expect(variations[0][:class]).to include('text-slate-400')
  end

  it 'stacks the phone variation under the amount and sizes the desktop one like the table text' do
    phone_variation = page.find('[data-month-row="phone"] [data-month-variation]', match: :first)
    desktop_variation = page.find('[data-month-row="desktop"] [data-month-variation]', match: :first)

    expect(phone_variation.tag_name).to eq('p')
    expect(phone_variation[:class]).to include('text-[10px]')
    expect(desktop_variation[:class]).to include('text-xs')
  end

  it 'opens the month in the month mode with the slice and the search' do
    expect(phone_rows.first[:href]).to eq('/history?categories%5B%5D=insurance&month=5&q=porto&types%5B%5D=expenses&year=2026')
  end

  it 'tells the phone how to open a month' do
    expect(page).to have_text(I18n.t('history.index.twelve_months.tap_hint'))
  end

  it 'lays the months out as a desktop table with month and variation columns' do
    table = page.find('table')

    expect(table.all('th').map(&:text).reject(&:empty?)).to eq(%w[Mês Tipo Descrição Variação Valor])
    expect(table.find('[data-month-row="desktop"]', match: :first)).to have_text('Mai/26')
    expect(table).to have_link(href: '/history?categories%5B%5D=insurance&month=1&q=porto&types%5B%5D=expenses&year=2026')
  end

  it 'shows an earning month in green with a plus sign' do
    trip = build_stubbed(:earning, date: Date.new(2026, 5, 3), amount: 32.5, platform: 'uber', trips_count: 1)
    earning_page = Capybara.string(view_context.render(described_class.new(rows: [rows.first.merge(total: 32.5, record: trip)],
                                                                           slice: History::Slice.new(platforms: %w[uber], range: '12m'), query: nil)))

    amount = earning_page.find('[data-month-row="phone"] [data-month-amount]')

    expect(amount.text).to eq("+R$\u00A032,50")
    expect(amount[:class]).to include('text-emerald-700')
  end
end
