require 'rails_helper'

RSpec.describe Dashboard::DeleteRefreshView, type: :component do
  let(:user) { create(:user) }

  before do
    allow(Current).to receive(:user).and_return(user)
    create(:earning, user: user, date: Date.new(2026, 1, 10), amount: 100, platform: 'uber')
    create(:expense, user: user, date: Date.new(2026, 1, 10), amount: 40, category: 'fuel', paid: true)
  end

  it 'renders the 7 turbo streams of a delete refresh' do
    filter  = { year: 2026, month: 1 }
    detail  = Dashboard::ExpensesDetailService.new(year: 2026, month: 1).call
    totals  = Dashboard::StatsService.new(year: 2026, month: 1).call

    output = view_context.render(
      described_class.new(
        detail_view: Dashboard::ExpensesDetailView.new(**detail, filters: filter),
        filter: filter,
        totals: totals
      )
    )

    expect(output).to include('target="modal"')
    expect(output).to include('target="stats_grid"')
    expect(output).to include('target="hero_profit_card"')
    expect(output).to include('target="today_card"')
    expect(output).to include('target="recent_activity"')
    expect(output).to include('target="category_breakdown"')
    expect(output).to include('target="flash_modal"')
  end
end
