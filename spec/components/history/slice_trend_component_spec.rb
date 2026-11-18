require 'rails_helper'

RSpec.describe History::SliceTrendComponent, type: :component do
  let(:months) do
    [[2025, 12, 80], [2026, 1, 0], [2026, 2, 0], [2026, 3, 0], [2026, 4, 100], [2026, 5, 125]]
      .map { |year, month, total| { year: year, month: month, total: total } }
  end
  let(:trend) { { kind: :expenses, months: months, change: 25.0, in_progress: false } }

  def render_trend(overrides = {}) = Capybara.string(view_context.render(described_class.new(trend: trend.merge(overrides))))

  let(:page) { render_trend }

  it 'titles the band by the slice kind' do
    expect(page).to have_text(I18n.t('history.index.slice_summary.trend_title.expenses'))
  end

  it 'draws one bar per month, scaled to the highest, the selected month strong' do
    bars = page.all('[data-trend-bar]')

    expect(bars.map { |bar| bar[:style] }).to eq(
      ['--bar: 0.64', '--bar: 0.0', '--bar: 0.0', '--bar: 0.0', '--bar: 0.8', '--bar: 1.0']
    )
    expect(bars.first[:class]).to include('bg-red-200')
    expect(bars.last[:class]).to include('bg-red-600')
  end

  it 'labels each bar with the short month name' do
    expect(page.all('[data-trend-label]').map(&:text)).to eq(%w[dez jan fev mar abr mai])
  end

  it 'shows the rise of an expense slice in red against the previous month' do
    expect(page.find('[data-trend-change]').text).to eq('+25%')
    expect(page.find('[data-trend-change]')[:class]).to include('font-semibold text-red-700')
    expect(page).to have_text(I18n.t('history.index.slice_summary.versus', month: 'abril'))
  end

  it 'shows a fall in slate, the earning bars in green and flags the month in progress' do
    falling = render_trend(kind: :earnings, change: -2.4, in_progress: true)

    expect(falling.find('[data-trend-change]').text).to eq('−2%')
    expect(falling.find('[data-trend-change]')[:class]).to include('text-slate-700')
    expect(falling.all('[data-trend-bar]').last[:class]).to include('bg-emerald-600')
    expect(falling).to have_text(I18n.t('history.index.slice_summary.in_progress'))
  end

  it 'leaves the comparison out when the previous month had nothing' do
    expect(render_trend(change: nil)).to have_no_css('[data-trend-change]')
  end
end
