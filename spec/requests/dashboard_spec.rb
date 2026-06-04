require 'rails_helper'

RSpec.describe 'Dashboard', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  describe 'GET /' do
    it 'renders the dashboard with earnings data' do
      create(:earning, user: current_user, date: Date.current, amount: 500)

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
      create(:earning, user: current_user, date: Date.new(2025, 6, 1),  amount: 500, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 2),  amount: 100, category: 'fuel', paid: true)

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
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber', trips_count: 4)
      create(:expense, user: current_user, date: Date.new(2025, 6, 12), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true)

      get root_path, params: { year: 2025, month: 6 }

      expect(response.body).to include(I18n.t('recent_activity_component.title'))
      expect(response.body).to include(I18n.t('category_breakdown_component.title'))
      expect(response.body).to include('Posto Shell')
      expect(response.body).to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
    end


    it 'renders topbar with greeting and subtitle' do
      get root_path, params: { year: 2025 }

      expect(response.body).to include(I18n.t('dashboard.index_view.greeting', name: current_user.first_name))
      expect(response.body).to include(I18n.t('dashboard.index_view.subtitle_period', year: 2025))
    end

    it 'renders "Novo lançamento" button hidden on mobile' do
      get root_path

      expect(response.body).to include(I18n.t('dashboard.index_view.new_record'))
      expect(response.body).to include('hidden lg:inline-flex')
    end

    it 'renders 12-column grid layout for hero and sidebar' do
      get root_path

      expect(response.body).to include('lg:grid-cols-12')
      expect(response.body).to include('lg:col-span-8')
      expect(response.body).to include('lg:col-span-4')
    end

    it 'renders today card when there is activity today' do
      create(:earning, user: current_user, date: Date.current, amount: 100, trips_count: 2)

      get root_path

      expect(response.body).to include(I18n.t('today_card_component.label'))
      expect(response.body).to include('100,00')
    end

    it 'does not render today card when no activity today' do
      get root_path

      expect(response.body).not_to include('tracking-wider text-slate-500')
    end

    it 'renders secondary grid with 7/5 column split' do
      get root_path

      expect(response.body).to include('lg:col-span-7')
      expect(response.body).to include('lg:col-span-5')
    end

    it 'renders stable IDs on home wrappers for turbo stream targets' do
      get root_path

      expect(response.body).to include('id="hero_profit_card"')
      expect(response.body).to include('id="today_card"')
      expect(response.body).to include('id="recent_activity"')
      expect(response.body).to include('id="category_breakdown"')
    end

    it 'keeps today_card wrapper in DOM even without activity today' do
      get root_path

      expect(response.body).to include('id="today_card"')
    end

    it 'renders sign out link in the sidebar' do
      get root_path

      expect(response.body).to include(I18n.t('sessions.sign_out'))
      expect(response.body).to include(session_path)
    end
  end

  describe 'GET /dashboard/earnings_detail' do
    it 'renders earnings detail in modal frame' do
      earning1 = create(:earning, user: current_user, date: Date.new(2025, 1, 15), amount: 100.50)
      create(:earning, user: current_user, date: Date.new(2025, 1, 20), amount: 250)

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
      create(:earning, user: current_user, date: Date.new(2025, 1, 15), amount: 100)
      create(:earning, user: current_user, date: Date.new(2025, 2, 10), amount: 250)
      create(:earning, user: current_user, date: Date.new(2025, 2, 20), amount: 50)

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
      expense1 = create(:expense, user: current_user, date: Date.new(2025, 1, 15), amount: 80, category: 'fuel', vendor: 'Posto Shell')
      create(:expense, user: current_user, date: Date.new(2025, 1, 15), amount: 25, category: 'meals', vendor: 'Lanchonete')
      create(:expense, user: current_user, date: Date.new(2025, 1, 20), amount: 150, category: 'maintenance', vendor: 'Oficina')

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

    it 'shows installment subtitle for paid parcels' do
      create(:expense,
             user: current_user,
             date: Date.new(2025, 1, 18),
             amount: 120,
             category: 'maintenance',
             vendor: 'Pneus',
             paid: true,
             installment_series_id: SecureRandom.uuid,
             installment_number: 1,
             installment_count: 3)

      get dashboard_expenses_detail_path(year: 2025, month: 1)

      expect(response.body).to include(I18n.t('dashboard.expenses_detail_view.installment_of', current: 1, total: 3))
    end

    it 'excludes unpaid expenses from the monthly detail list and total' do
      create(:expense, user: current_user, date: Date.new(2025, 1, 10), amount: 80, category: 'fuel', vendor: 'Posto Paid', paid: true)
      create(:expense, user: current_user, date: Date.new(2025, 1, 12), amount: 120, category: 'maintenance', vendor: 'Oficina Unpaid', paid: false)

      get dashboard_expenses_detail_path(year: 2025, month: 1)

      expect(response.body).to include('Posto Paid')
      expect(response.body).not_to include('Oficina Unpaid')
      expect(response.body).to include('80,00')
      expect(response.body).not_to include('120,00')
    end

    it 'shows empty state when no expenses in period' do
      get dashboard_expenses_detail_path(year: 2020, month: 1)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('dashboard.expenses_detail_view.empty'))
    end

    it 'renders annual view with monthly totals when no month filter' do
      create(:expense, user: current_user, date: Date.new(2025, 1, 10), amount: 100, category: 'fuel')
      create(:expense, user: current_user, date: Date.new(2025, 2, 15), amount: 200, category: 'maintenance')

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

  describe 'data isolation between users' do
    let(:other_user) { create(:user) }

    it 'does not show earnings from another user on the dashboard' do
      create(:earning, user: other_user, amount: 8_888.00, date: Date.current)

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('8.888')
    end

    it 'does not show expenses from another user on the dashboard' do
      create(:expense, user: other_user, amount: 7_777.00, date: Date.current)

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('7.777')
    end

    it 'shows only the current user earnings even when another user has records' do
      create(:earning, user: current_user, amount: 1_234.00, date: Date.current)
      create(:earning, user: other_user,   amount: 9_876.00, date: Date.current)

      get root_path

      expect(response.body).to include('1.234')
      expect(response.body).not_to include('9.876')
    end
  end
end
