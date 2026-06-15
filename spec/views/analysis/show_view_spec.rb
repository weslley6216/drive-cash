require 'rails_helper'

RSpec.describe Analysis::ShowView, type: :component do
  let(:insights) do
    {
      metrics: { per_day: 0, per_trip: 0, per_hour: 0, margin: 0, change_pct: {} },
      monthly_bars: [], categories: [], platforms: [], insights: [],
      period_context: nil
    }
  end
  let(:filters) { { year: 2026, month: nil, available_years: [2026] } }

  it 'wraps page content in turbo_frame page so filter updates do not reload nav' do
    html = view_context.render(described_class.new(insights: insights, filters: filters))

    expect(html).to include('id="page"')
  end
end
