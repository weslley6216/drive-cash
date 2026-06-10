require 'rails_helper'

RSpec.describe Dashboard::IndexView, type: :component do
  let(:user) { create(:user) }
  let(:totals) do
    {
      profit: 0.0, change_percent: 0.0, profit_per_day: 0.0, days: 0,
      daily_profit_series: [], monthly_profit_series: [],
      earnings: 0.0, expenses: 0.0
    }
  end
  let(:filters) { { year: 2026, month: nil, available_years: [2026] } }

  before { allow(Current).to receive(:user).and_return(user) }

  it 'wraps page content in turbo_frame page so filter updates do not reload nav' do
    html = view_context.render(
      described_class.new(totals: totals, filters: filters, recent_activity: [], categories: [])
    )

    expect(html).to include('<turbo-frame id="page">')
  end
end
