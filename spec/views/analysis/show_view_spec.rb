require 'rails_helper'

RSpec.describe Analysis::ShowView, type: :component do
  let(:empty_series) { { points: [], best: nil } }
  let(:base_insights) do
    {
      metrics: {
        earnings: 100, expenses: 0, per_day: 0, per_trip: 0, per_km: nil, margin: 0,
        series: { per_day: empty_series, per_trip: empty_series, per_km: empty_series, margin: empty_series }
      },
      monthly_bars: [], categories: [], platforms: [], platforms_total: 0, insights: [], empty: false, last_month_with_data: nil
    }
  end
  let(:filters) { { year: 2026, month: nil, available_years: [2026] } }

  it 'wraps page content in turbo_frame page so filter updates do not reload nav' do
    html = view_context.render(described_class.new(insights: base_insights, filters: filters))

    expect(html).to include('id="page"')
  end

  it 'renders em dash for per_km when value is nil' do
    html = view_context.render(described_class.new(insights: base_insights, filters: filters))

    expect(html).to include('—')
  end

  it 'renders formatted per_km value when present' do
    insights_with_km = base_insights.deep_merge(metrics: { per_km: 1.5 })

    html = view_context.render(described_class.new(insights: insights_with_km, filters: filters))

    expect(html).to include('1,50')
  end

  it 'renders the per km card as the hero ahead of the other metrics' do
    html = view_context.render(described_class.new(insights: base_insights, filters: filters))

    expect(html.index('Lucro por km rodado')).to be < html.index('R$ / dia')
    expect(html).to include('lg:grid-cols-[1.4fr_1fr_1fr_1fr]')
  end

  it 'renders the margin as money under the "Sobra a cada R$ 100" label' do
    insights_with_margin = base_insights.deep_merge(metrics: { margin: 56.1 })

    html = view_context.render(described_class.new(insights: insights_with_margin, filters: filters))

    expect(html).to include('Sobra a cada R$ 100')
    expect(html).to include('R$ 56,10')
    expect(html).not_to include('Margem')
  end

  it 'renders the platforms total from the service payload, not the sum of displayed rows' do
    insights = base_insights.merge(
      platforms:       [{ id: 'uber', label: 'Uber', amount: 900, percent: 60 }],
      platforms_total: 1500
    )

    html = view_context.render(described_class.new(insights: insights, filters: filters))

    expect(html).to include('1.500')
  end

  describe 'empty period' do
    let(:empty_insights) { base_insights.deep_merge(metrics: { earnings: 0 }).merge(empty: true) }
    let(:july) { { year: 2026, month: 7, available_years: [2026] } }

    it 'links the empty state to the last month with data' do
      insights = empty_insights.merge(last_month_with_data: Date.new(2026, 6, 1))

      html = view_context.render(described_class.new(insights: insights, filters: july))

      expect(html).to include('Ver junho, o último mês com dados →')
      expect(html).to include(%(href="/analysis?month=6&amp;year=2026"))
    end

    it 'adds the year to the shortcut when the last month with data is from another year' do
      insights = empty_insights.merge(last_month_with_data: Date.new(2025, 12, 1))

      html = view_context.render(described_class.new(insights: insights, filters: july))

      expect(html).to include('Ver dezembro de 2025, o último mês com dados →')
      expect(html).to include(%(href="/analysis?month=12&amp;year=2025"))
    end

    it 'omits the shortcut when there is no earlier month with data' do
      html = view_context.render(described_class.new(insights: empty_insights, filters: july))

      expect(html).to include('Sem dados em julho')
      expect(html).not_to include('o último mês com dados')
    end

    it 'renders the charts when the service says the period has data' do
      html = view_context.render(described_class.new(insights: base_insights, filters: july))

      expect(html).not_to include('Sem dados em julho')
      expect(html).to include('Lucro por km rodado')
    end
  end
end
