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

    it 'renders the dashed hero and the empty state when the period has no records' do
      get root_path

      expect(response.body).to include(I18n.t('empty_states.home.title'))
      expect(response.body).to include(I18n.t('empty_states.home.hero_placeholder'))
    end

    it 'renders the stats grid when the period has records' do
      create(:earning, user: current_user, date: Date.current)

      get root_path

      expect(response.body).not_to include(I18n.t('empty_states.home.title'))
      expect(response.body).to include(I18n.t('dashboard.index_view.stats.trips.title'))
    end

    it 'renders the empty state for a filtered year without records' do
      past_year = Date.current.year - 1

      get root_path, params: { year: past_year }

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('empty_states.home.hero_label', year: past_year))
    end

    it 'renders bottom nav with home tab active' do
      get root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('fixed bottom-0 left-0 right-0')
      expect(response.body).to include('text-blue-600')
      expect(response.body).to include('h-full max-w-7xl mx-auto flex flex-col min-h-0 lg:px-8')
      expect(response.body).to include('fixed bottom-24 right-5')
    end

    it 'renders static chrome: topbar greeting, new record button, loading region, and sidebar links' do
      get root_path, params: { year: 2025 }

      expect(response.body).to include(I18n.t('dashboard.index_view.greeting', name: current_user.first_name))
      expect(response.body).to include(I18n.t('dashboard.index_view.subtitle_period', year: 2025))
      expect(response.body).to include(I18n.t('dashboard.index_view.new_record'))
      expect(response.body).to match(%r{<a data-turbo-frame="_top" class="hidden lg:inline-flex[^>]*href="/records/new"})
      expect(response.body).to include('hidden lg:inline-flex')
      expect(response.body).to include('feed-loading-region')
      expect(response.body).to include('<div class="feed-loading-region flex-1 flex flex-col min-h-0"><div class="feed-loading-overlay">')
      expect(response.body).to include(I18n.t('sidebar_nav_component.account_hint'))
      expect(response.body).to include('w-9 h-9 rounded-full bg-white border border-slate-200 shadow-sm')
      expect(response.body).to include('w-9 h-9 rounded-full bg-blue-600 text-white')
    end

    it 'renders the prototype header: brand eyebrow on phones, white topbar on desktops' do
      get root_path, params: { year: 2025 }

      expect(response.body).to include(%(<p class="text-xs font-medium text-slate-500 uppercase tracking-wider lg:hidden">#{I18n.t('dashboard.index_view.eyebrow')}</p>))
      expect(response.body).to include('px-5 pt-2 pb-3 sm:px-6 sm:pt-6 flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between lg:gap-6 lg:-mx-8 lg:px-8 lg:py-4 lg:bg-white lg:border-b lg:border-slate-200')
      expect(response.body).to include(%(<p class="hidden lg:block text-sm text-slate-500 mt-0.5">#{I18n.t('dashboard.index_view.subtitle_period', year: 2025)}</p>))
      expect(response.body.scan('w-9 h-9 rounded-full bg-blue-600 text-white').size).to eq(1)
    end

    it 'hides the period filter on the first use, before any record exists' do
      get root_path

      expect(response.body).to include(I18n.t('empty_states.home.title'))
      expect(response.body).not_to include('data-controller="filter"')
      expect(response.body).to include('<div class="bg-white rounded-xl shadow-sm border border-slate-100">')
    end

    it 'keeps the period filter on an empty year when the user has records in another year' do
      create(:earning, user: current_user, date: Date.new(2024, 3, 1), amount: 100)

      get root_path

      expect(response.body).to include(I18n.t('empty_states.home.title'))
      expect(response.body).to include('data-controller="filter"')
    end

    it 'shows the today card on every screen size' do
      create(:earning, user: current_user, date: Date.current, amount: 100, platform: 'uber')

      get root_path

      expect(response.body).to include('<div id="today_card"><div class="rounded-2xl bg-white')
    end

    it 'renders hero profit card section' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 1), amount: 500, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 2), amount: 100, category: 'fuel', paid: true)

      get root_path, params: { year: 2025 }

      expect(response.body).to include('bg-blue-50')
      expect(response.body).to include('border-blue-200')
      expect(response.body).to include(I18n.t('hero_profit_card_component.label_year', year: 2025))
    end

    it 'renders caju quick access linking to /chat' do
      create(:earning, user: current_user, date: Date.current)

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


    it 'renders the notification bell linking to the center on both headers' do
      create(:notification, user: current_user)

      get root_path

      expect(response.body.scan('href="/notifications"').size).to eq(2)
      expect(response.body.scan(NotificationBellComponent::BADGE_CLASSES).size).to eq(2)
    end

    it 'does not count dismissed notifications in the bell badge' do
      create(:notification, user: current_user)
      create(:notification, user: current_user, dismissed_at: Time.current)

      get root_path

      expect(response.body).to include('>1<')
    end

    it 'ignores disabled kinds in the bell badge' do
      create(:notification, user: current_user, kind: 'tank_low', data: { 'status' => 'negative' })
      create(:notification, user: current_user, kind: 'log_reminder')
      current_user.update!(notification_settings: current_user.notification_settings.with('log_reminder', false))

      get root_path

      expect(response.body).to include('>1<')
    end

    it 'renders 12-column grid layout for hero and sidebar' do
      create(:earning, user: current_user, date: Date.current)

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
      travel_to Date.new(2026, 6, 15) do
        create(:earning, user: current_user, date: Date.new(2026, 6, 10))

        get root_path

        expect(response.body).not_to include('tracking-wider text-slate-500')
      end
    end

    it 'renders secondary grid with 7/5 column split' do
      create(:earning, user: current_user, date: Date.current)

      get root_path

      expect(response.body).to include('lg:col-span-7')
      expect(response.body).to include('lg:col-span-5')
    end

    it 'renders stable IDs on home wrappers for turbo stream targets' do
      create(:earning, user: current_user, date: Date.current)

      get root_path

      expect(response.body).to include('id="hero_profit_card"')
      expect(response.body).to include('id="today_card"')
      expect(response.body).to include('id="recent_activity"')
      expect(response.body).to include('id="category_breakdown"')
    end

    it 'keeps today_card wrapper in DOM even without activity today' do
      travel_to Date.new(2026, 6, 15) do
        create(:earning, user: current_user, date: Date.new(2026, 6, 10))

        get root_path

        expect(response.body).to include('id="today_card"')
      end
    end

    it 'renders monthly goal card visible only on mobile after stats grid' do
      create(:earning, user: current_user, date: Date.current)
      create(:goal, user: current_user, kind: 'monthly',
                    period_start: Date.current.beginning_of_month,
                    period_end: Date.current.end_of_month,
                    target_amount: 5000)

      get root_path

      expect(response.body).to include('class="lg:hidden mb-4"')
      stats_position = response.body.index('grid-cols-2') || response.body.index(I18n.t('stats_grid_component.income'))
      mobile_card_position = response.body.index('class="lg:hidden mb-4"')
      expect(mobile_card_position).to be > stats_position
    end

    it 'keeps mobile monthly_goal wrapper in DOM even without an active goal' do
      create(:earning, user: current_user, date: Date.current)

      get root_path

      expect(response.body).to include('class="lg:hidden mb-4"')
      expect(response.body).not_to include(I18n.t('goals.index.monthly.label'))
    end

    it 'renders monthly goal card when filtered month matches an active goal' do
      create(:earning, user: current_user, date: Date.new(2026, 3, 10))
      create(:goal, user: current_user, kind: 'monthly',
                    period_start: Date.new(2026, 3, 1),
                    period_end: Date.new(2026, 3, 31),
                    target_amount: 5000)

      get root_path, params: { year: 2026, month: 3 }

      expect(response.body).to include(I18n.t('goals.index.monthly.label'))
      expect(response.body).to include('5.000,00')
    end

    it 'counts days remaining from today when the filtered month is the current month' do
      travel_to Date.new(2026, 6, 12) do
        create(:earning, user: current_user, date: Date.new(2026, 6, 5))
        create(:goal, user: current_user, kind: 'monthly',
                      period_start: Date.new(2026, 6, 1),
                      period_end: Date.new(2026, 6, 30),
                      target_amount: 5000)

        get root_path, params: { year: 2026, month: 6 }

        expect(response.body).to include(I18n.t('goals.index.monthly.days_left', count: 19))
      end
    end

    it 'shows the final result without a countdown for a goal from a past month' do
      travel_to Date.new(2026, 7, 15) do
        create(:earning, user: current_user, date: Date.new(2026, 3, 10), amount: 100)
        create(:expense, user: current_user, date: Date.new(2026, 3, 10), amount: 100, category: 'fuel', paid: true)
        create(:goal, user: current_user, kind: 'monthly',
                      period_start: Date.new(2026, 3, 1),
                      period_end: Date.new(2026, 3, 31),
                      target_amount: 5000)

        get root_path, params: { year: 2026, month: 3 }

        expect(response.body).to include(I18n.t('goals.index.monthly.missed', shortfall: 'R$ 5.000,00'))
        expect(response.body).not_to include('dias restantes')
      end
    end

    it 'does not render monthly goal card when filtered month has no active goal' do
      create(:earning, user: current_user, date: Date.new(2026, 3, 10))
      create(:goal, user: current_user, kind: 'monthly',
                    period_start: Date.new(2026, 6, 1),
                    period_end: Date.new(2026, 6, 30),
                    target_amount: 5000)

      get root_path, params: { year: 2026, month: 3 }

      expect(response.body).not_to include(I18n.t('goals.index.monthly.label'))
    end

    it 'renders monthly goal card on annual view when current month has an active goal' do
      create(:earning, user: current_user, date: Date.current)
      create(:goal, user: current_user, kind: 'monthly',
                    period_start: Date.current.beginning_of_month,
                    period_end: Date.current.end_of_month,
                    target_amount: 5000)

      get root_path, params: { year: Date.current.year }

      expect(response.body).to include(I18n.t('goals.index.monthly.label'))
    end

    it 'shows the current monthly goal on the current-year Todos view' do
      travel_to Date.new(2026, 7, 15) do
        create(:goal, user: current_user, kind: 'monthly',
                      period_start: Date.current.beginning_of_month,
                      period_end: Date.current.end_of_month,
                      target_amount: 5000)
        create(:earning, user: current_user, date: Date.current)

        get root_path, params: { year: 2026 }

        expect(response.body).to include(I18n.t('goals.index.monthly.label'))
      end
    end

    it 'hides the monthly hero on a past-year Todos view' do
      travel_to Date.new(2026, 7, 15) do
        create(:goal, user: current_user, kind: 'monthly',
                      period_start: Date.current.beginning_of_month,
                      period_end: Date.current.end_of_month,
                      target_amount: 5000)
        create(:earning, user: current_user, date: Date.new(2025, 3, 10), amount: 500)

        get root_path, params: { year: 2025 }

        expect(response.body).not_to include(I18n.t('goals.index.monthly.label'))
      end
    end

    it 'loads the home of a selected month within ten queries' do
      travel_to Time.zone.local(2026, 3, 15, 10, 0)
      create(:earning, user: current_user, date: Date.new(2026, 3, 15), amount: 500)
      create(:expense, user: current_user, date: Date.new(2026, 3, 10), amount: 120, category: 'fuel', paid: true)
      create(:goal, user: current_user, kind: 'monthly', metric: 'profit', target_amount: 1000,
             period_start: Date.new(2026, 3, 1), period_end: Date.new(2026, 3, 31))

      queries = count_queries { get root_path, params: { year: 2026, month: 3 } }

      expect(queries).to be <= 10
      expect(response.body.squish).to include('380,00')
    end
  end

  describe 'GET /dashboard/earnings_detail' do
    it 'renders earnings detail in modal frame' do
      earning1 = create(:earning, user: current_user, date: Date.new(2025, 1, 15), amount: 100.50)
      create(:earning, user: current_user, date: Date.new(2025, 1, 20), amount: 250)

      get dashboard_earnings_detail_path(year: 2025, month: 1)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.title_month'))
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
      expect(response.body).to include(I18n.t('date.month_names')[1].capitalize)
      expect(response.body).to include(I18n.t('date.month_names')[2].capitalize)
      expect(response.body).to include('100,00')
      expect(response.body).to include('300,00')
      expect(response.body).to include('400,00')
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.total'))
    end
  end

  describe 'detail modal chrome' do
    it 'draws the annual earnings card like the prototype: accent top border, total title, chevrons and tight paddings' do
      create(:earning, user: current_user, date: Date.new(2025, 1, 15), amount: 100)

      get dashboard_earnings_detail_path(year: 2025)

      expect(response.body).to include('bg-white rounded-2xl shadow-2xl w-full max-w-[380px]')
      expect(response.body).to include('border-t-4 border-t-blue-600')
      expect(response.body).to include(%(<h2 class="text-lg font-bold tracking-tight text-blue-600 truncate">#{I18n.t('dashboard.earnings_detail_view.title')}</h2>))
      expect(response.body).to include('<p class="text-sm text-slate-500 mt-0.5">2025</p>')
      expect(response.body).to include('w-[15px] h-[15px] text-slate-300')
      expect(response.body).to include('class="text-green-700">R$ 100,00</span>')
      expect(response.body).to include('px-4 py-2 rounded-lg border border-slate-300 text-slate-700 text-sm font-medium')
    end

    it 'lists the month earnings as day/month with the actions before the amount' do
      create(:earning, user: current_user, date: Date.new(2025, 1, 15), amount: 100)

      get dashboard_earnings_detail_path(year: 2025, month: 1)

      expect(response.body).to include('>15/01</td>')
      expect(response.body).to include('<p class="text-sm text-slate-500 mt-0.5">Janeiro · 2025</p>')
      expect(response.body).to include('overflow-y-auto px-5 py-3 max-h-[360px]')
      expect(response.body).to match(/aria-label="#{I18n.t('dashboard.earnings_detail_view.edit')}".*R\$ 100,00/m)
    end

    it 'groups the month expenses under a short day label in the red theme' do
      create(:expense, user: current_user, date: Date.new(2025, 1, 15), amount: 80, category: 'fuel', vendor: 'Posto Shell')

      get dashboard_expenses_detail_path(year: 2025, month: 1)

      expect(response.body).to include('>15 jan</p>')
      expect(response.body).to include('border-t-4 border-t-red-600')
      expect(response.body).to include('class="text-red-700">R$ 80,00</span>')
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
      expect(response.body).to include(I18n.t('dashboard.expenses_detail_view.title_month'))
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
             user:                  current_user,
             date:                  Date.new(2025, 1, 18),
             amount:                120,
             category:              'maintenance',
             vendor:                'Pneus',
             paid:                  true,
             installment_series_id: SecureRandom.uuid,
             installment_number:    1,
             installment_count:     3)

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
      expect(response.body).to include(I18n.t('date.month_names')[1].capitalize)
      expect(response.body).to include(I18n.t('date.month_names')[2].capitalize)
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
      create(:earning, user: other_user, amount: 9_876.00, date: Date.current)

      get root_path

      expect(response.body).to include('1.234')
      expect(response.body).not_to include('9.876')
    end
  end
end
