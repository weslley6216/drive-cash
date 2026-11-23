require 'rails_helper'

RSpec.describe History::MonthBarsComponent, type: :component do
  let(:months) { [[2025, 12, 80], [2026, 1, 0], [2026, 2, 100]].map { |year, month, total| { year: year, month: month, total: total } } }

  it 'scales the bars to the highest month and labels them, the last label bold' do
    page = Capybara.string(view_context.render(described_class.new(months: months, earnings: false, highlighted: [2])))

    expect(page.all('[data-trend-bar]').map { |bar| bar[:style] }).to eq(['--bar: 0.8', '--bar: 0.0', '--bar: 1.0'])
    expect(page.all('[data-trend-label]').map(&:text)).to eq(%w[dez jan fev])
    expect(page.all('[data-trend-label]').last[:class]).to include('font-bold text-slate-700')
  end

  it 'paints the highlighted bars strong in red for expenses and green for earnings' do
    expense_bars = Capybara.string(view_context.render(described_class.new(months: months, earnings: false,
                                                                           highlighted: [1, 2]))).all('[data-trend-bar]')
    earning_bars = Capybara.string(view_context.render(described_class.new(months: months, highlighted: [2],
                                                                           earnings: true))).all('[data-trend-bar]')

    expect(expense_bars.map { |bar| bar[:class][/bg-red-\d+/] }).to eq(%w[bg-red-200 bg-red-600 bg-red-600])
    expect(earning_bars.map { |bar| bar[:class][/bg-emerald-\d+/] }).to eq(%w[bg-emerald-200 bg-emerald-200 bg-emerald-600])
  end

  it 'sizes the bars for the twelve month card' do
    bar = Capybara.string(view_context.render(described_class.new(months: months, earnings: false, highlighted: [2],
                                                                  size: :year))).find('[data-trend-bar]', match: :first)

    expect(bar[:class]).to include('h-[max(3px,calc(var(--bar)*64px))] lg:h-[max(3px,calc(var(--bar)*80px))]')
  end
end
