require 'rails_helper'

RSpec.describe Analysis::ShowView, type: :component do
  let(:base_insights) do
    {
      metrics: { per_day: 0, per_trip: 0, per_km: nil, margin: 0, change_pct: {} },
      monthly_bars: [], categories: [], platforms: [], insights: [],
      period_context: nil
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
    expect(html).to include(I18n.t('analysis.show_view.metrics.per_km_empty'))
  end

  it 'renders formatted per_km value when present' do
    insights_with_km = base_insights.deep_merge(metrics: { per_km: 1.5 })

    html = view_context.render(described_class.new(insights: insights_with_km, filters: filters))

    expect(html).to include('1,50')
    expect(html).to include(I18n.t('analysis.show_view.metrics.per_km_hint'))
  end
end
