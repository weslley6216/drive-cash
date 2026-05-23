require 'rails_helper'

RSpec.describe 'Dashboard', type: :request do
  describe 'GET /' do
    it 'renders the dashboard with earnings data' do
      create(:earning, date: Date.current, amount: 500)

      get root_path

      expect(response).to have_http_status(:success)
      expect(response.body.squish).to include('500,00')
    end

    it 'filters by year and shows zero when no data exists' do
      past_year = Date.current.year - 1

      get root_path, params: { year: past_year }

      expect(response).to have_http_status(:success)
      expect(response.body).to include('0,00')
    end

    it 'renders bottom nav with home tab active' do
      get root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('fixed bottom-0 left-0 right-0')
      expect(response.body).to include('text-blue-600')
      expect(response.body).to include('max-w-7xl mx-auto pb-24')
      expect(response.body).to include('fixed bottom-24 right-6')
    end

    it 'renders hero profit card section' do
      create(:earning, date: Date.new(2025, 6, 1),  amount: 500, platform: 'uber')
      create(:expense, date: Date.new(2025, 6, 2),  amount: 100, category: 'fuel', paid: true)

      get root_path, params: { year: 2025 }

      expect(response.body).to include('bg-blue-50')
      expect(response.body).to include('border-blue-200')
      expect(response.body).to include(I18n.t('hero_profit_card_component.label_year', year: 2025))
    end

    it 'renders caju quick access linking to /chat' do
      get root_path

      expect(response.body).to include(I18n.t('caju_quick_access_component.title'))
      expect(response.body).to include('href="/chat"')
    end

    it 'renders recent activity and breakdown sections' do
      create(:earning, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber', trips_count: 4)
      create(:expense, date: Date.new(2025, 6, 12), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true)

      get root_path, params: { year: 2025, month: 6 }

      expect(response.body).to include(I18n.t('recent_activity_component.title'))
      expect(response.body).to include(I18n.t('category_breakdown_component.title'))
      expect(response.body).to include('Posto Shell')
      expect(response.body).to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
    end
  end

  describe 'GET /dashboard/earnings_detail' do
    it 'renders earnings detail in modal frame' do
      earning1 = create(:earning, date: Date.new(2025, 1, 15), amount: 100.50)
      create(:earning, date: Date.new(2025, 1, 20), amount: 250)

      get dashboard_earnings_detail_path(year: 2025, month: 1)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.title'))
      expect(response.body).to include('100,50')
      expect(response.body).to include('250,00')
      expect(response.body).to include('350,50')
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.total'))
      expect(response.body).to include(edit_earning_path(earning1))
    end

    it 'shows empty state when no earnings in period' do
      get dashboard_earnings_detail_path(year: 2020, month: 1)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.empty'))
    end

    it 'renders annual view with monthly totals when no month filter' do
      create(:earning, date: Date.new(2025, 1, 15), amount: 100)
      create(:earning, date: Date.new(2025, 2, 10), amount: 250)
      create(:earning, date: Date.new(2025, 2, 20), amount: 50)

      get dashboard_earnings_detail_path(year: 2025)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.columns.month'))
      expect(response.body).to include(I18n.t('date.month_names')[1])
      expect(response.body).to include(I18n.t('date.month_names')[2])
      expect(response.body).to include('100,00')
      expect(response.body).to include('300,00')
      expect(response.body).to include('400,00')
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.total'))
    end
  end

  describe 'GET /dashboard/expenses_detail' do
    it 'renders expenses detail in modal frame with date grouping' do
      expense1 = create(:expense, date: Date.new(2025, 1, 15), amount: 80, category: 'fuel', vendor: 'Posto Shell')
      create(:expense, date: Date.new(2025, 1, 15), amount: 25, category: 'meals', vendor: 'Lanchonete')
      create(:expense, date: Date.new(2025, 1, 20), amount: 150, category: 'maintenance', vendor: 'Oficina')

      get dashboard_expenses_detail_path(year: 2025, month: 1)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include(I18n.t('dashboard.expenses_detail_view.title'))
      expect(response.body).to include('Posto Shell')
      expect(response.body).to include('Lanchonete')
      expect(response.body).to include('Oficina')
      expect(response.body).to include('80,00')
      expect(response.body).to include('25,00')
      expect(response.body).to include('150,00')
      expect(response.body).to include('255,00')
      expect(response.body).to include(I18n.t('dashboard.expenses_detail_view.total'))
      expect(response.body).to include(edit_expense_path(expense1))
    end

    it 'shows installment subtitle and pending status for unpaid parcels' do
      create(:expense,
             date: Date.new(2025, 1, 18),
             amount: 120,
             category: 'maintenance',
             vendor: 'Pneus',
             paid: false,
             installment_series_id: SecureRandom.uuid,
             installment_number: 1,
             installment_count: 3)

      get dashboard_expenses_detail_path(year: 2025, month: 1)

      expect(response.body).to include(I18n.t('dashboard.expenses_detail_view.installment_of', current: 1, total: 3))
      expect(response.body).to include(I18n.t('dashboard.expenses_detail_view.status_pending'))
    end

    it 'shows empty state when no expenses in period' do
      get dashboard_expenses_detail_path(year: 2020, month: 1)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('dashboard.expenses_detail_view.empty'))
    end

    it 'renders annual view with monthly totals when no month filter' do
      create(:expense, date: Date.new(2025, 1, 10), amount: 100, category: 'fuel')
      create(:expense, date: Date.new(2025, 2, 15), amount: 200, category: 'maintenance')

      get dashboard_expenses_detail_path(year: 2025)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('date.month_names')[1])
      expect(response.body).to include(I18n.t('date.month_names')[2])
      expect(response.body).to include('100,00')
      expect(response.body).to include('200,00')
      expect(response.body).to include('300,00')
      expect(response.body).to include(I18n.t('dashboard.expenses_detail_view.total'))
    end
  end
end
