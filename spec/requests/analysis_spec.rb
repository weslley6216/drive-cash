require 'rails_helper'

RSpec.describe 'Analysis', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  describe 'GET /analysis' do
    it 'responds 200' do
      get analysis_path

      expect(response).to have_http_status(:success)
    end

    it 'renders the bottom nav with analysis tab active' do
      get analysis_path

      expect(response.body).to include('text-blue-600')
      expect(response.body).to include(I18n.t('bottom_nav_component.tabs.analysis'))
    end

    it 'renders the page title' do
      get analysis_path

      expect(response.body).to include(I18n.t('analysis.show_view.title'))
    end

    it 'wraps the content in a localized loading region for filter navigations' do
      get analysis_path

      expect(response.body).to include('feed-loading-region')
      expect(response.body).to include('feed-loading-overlay')
    end

    it 'renders the empty state when the period has no records' do
      get analysis_path(year: Date.current.year, month: Date.current.month)

      expect(response.body).to include(I18n.t('empty_states.analysis.cta'))
    end

    it 'renders the charts when the period has records' do
      create(:earning, user: current_user, date: Date.current)

      get analysis_path(year: Date.current.year, month: Date.current.month)

      expect(response.body).not_to include(I18n.t('empty_states.analysis.cta'))
    end

    it 'renders the per km hero and the three compact metric cards' do
      create(:earning, user: current_user, date: Date.current, amount: 200, trips_count: 4)

      get analysis_path

      expect(response.body).to include(I18n.t('analysis.show_view.metrics.per_km_hero'))
      expect(response.body).to include(I18n.t('analysis.show_view.metrics.per_day'))
      expect(response.body).to include(I18n.t('analysis.show_view.metrics.per_trip'))
      expect(response.body).to include(I18n.t('analysis.show_view.metrics.margin'))
      expect(response.body).to include('grid-cols-2')
      expect(response.body).not_to include('melhor:')
    end

    it 'renders the trend footer once there are three months with earnings' do
      create(:earning, user: current_user, date: Date.new(2025, 1, 10), amount: 100)
      create(:earning, user: current_user, date: Date.new(2025, 2, 10), amount: 100)
      create(:earning, user: current_user, date: Date.new(2025, 3, 10), amount: 100)

      get analysis_path, params: { year: 2025 }

      expect(response.body).to include('melhor:')
      expect(response.body).to include('<svg')
    end

    it 'renders the bar chart section' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 1), amount: 500)

      get analysis_path, params: { year: 2025 }

      expect(response.body).to include(I18n.t('analysis.show_view.bar_chart.title'))
      expect(response.body).to include('bg-emerald-500')
      expect(response.body).to include('bg-red-500')
    end

    it 'renders the category breakdown with total_annual subtitle when no month selected' do
      create(:expense, user: current_user, date: Date.new(2025, 6, 1), amount: 100, category: 'fuel', paid: true)

      get analysis_path, params: { year: 2025 }

      expect(response.body).to include(I18n.t('analysis.show_view.categories.title'))
      expect(response.body).to include('no ano')
    end

    it 'renders the category breakdown with total_monthly subtitle when month is selected' do
      create(:expense, user: current_user, date: Date.new(2025, 6, 1), amount: 100, category: 'fuel', paid: true)

      get analysis_path, params: { year: 2025, month: 6 }

      expect(response.body).to include(I18n.t('analysis.show_view.categories.title'))
      expect(response.body).to include('no mês')
    end

    it 'renders the platform donut with stroke-dasharray and center label' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 1), amount: 100, platform: 'uber')

      get analysis_path, params: { year: 2025, month: 6 }

      expect(response.body).to include(I18n.t('analysis.show_view.platforms.title'))
      expect(response.body).to include('stroke-dasharray')
      expect(response.body).to include(I18n.t('analysis.show_view.platforms.total_label'))
    end

    it 'renders an insight card in amber (rounded-2xl bg-amber-50) when there is data to analyze' do
      create(:expense, user: current_user, date: Date.new(2025, 2, 1), amount: 220, category: 'fuel', paid: true)
      create(:expense, user: current_user, date: Date.new(2025, 1, 1), amount: 100, category: 'fuel', paid: true)

      get analysis_path, params: { year: 2025, month: 2 }

      expect(response.body).to include('rounded-2xl')
      expect(response.body).to include('bg-amber-50')
      expect(response.body).to include('text-amber-900')
    end

    it 'links the category insight to the history filtered by the category and the month' do
      create(:expense, user: current_user, date: Date.new(2025, 2, 1), amount: 220, category: 'fuel', paid: true)

      get analysis_path, params: { year: 2025, month: 2 }

      expect(response.body).to include(%(href="#{CGI.escapeHTML(history_path(filter: 'fuel', year: 2025, month: 2))}"))
      expect(response.body).to include(I18n.t('analysis.show_view.insights.category_share.link'))
    end

    it 'links the annual category insight to the history of the whole year' do
      create(:expense, user: current_user, date: Date.new(2025, 2, 1), amount: 220, category: 'fuel', paid: true)

      get analysis_path, params: { year: 2025 }

      expect(response.body).to include(%(href="#{CGI.escapeHTML(history_path(filter: 'fuel', year: 2025))}"))
    end

    it 'titles the dimmed chart frame of the empty state like the prototype' do
      get analysis_path(year: 2026, month: 7)

      expect(response.body).to include(%(<p class="text-sm font-semibold text-slate-700 mb-3">#{I18n.t('analysis.show_view.empty_chart_title')}</p>))
      expect(I18n.t('analysis.show_view.empty_chart_title')).to eq('Receita × Despesa')
      expect(response.body).to include('bg-white rounded-xl shadow-sm border border-slate-100 p-4')
      expect(response.body).not_to include('rounded-2xl border border-slate-100 shadow-sm')
    end

    it 'renders the prototype topbar with the white desktop bar and the export shortcut' do
      get analysis_path

      expect(response.body).to include('px-5 pt-2 pb-3 sm:px-6 sm:pt-6 lg:-mx-8 lg:px-8 lg:py-4 lg:bg-white lg:border-b lg:border-slate-200')
      expect(response.body).to include('text-2xl font-bold text-slate-800 leading-tight lg:leading-8 lg:text-slate-900 lg:tracking-tight')
      expect(response.body).to include(%(href="#{exports_path}"))
      expect(response.body).to include(I18n.t('analysis.show_view.export'))
    end

    it 'keeps the platform donut for desktops and spaces the sections like the prototype' do
      create(:earning, user: current_user, date: Date.current, amount: 500, platform: 'uber')
      create(:expense, user: current_user, date: Date.current, amount: 100, category: 'fuel', paid: true)

      get analysis_path

      expect(response.body).to include('id="platform_breakdown" class="hidden lg:block lg:col-span-5"')
      expect(response.body).to include('overflow-y-auto px-5 sm:px-6 pb-3.5 lg:px-0 lg:pb-8 lg:pt-8')
      expect(response.body).to include('<div class="space-y-4 lg:space-y-6">')
    end

    it 'filters by year and month query params' do
      create(:earning, user: current_user, date: Date.new(2024, 6, 1), amount: 999)
      create(:earning, user: current_user, date: Date.new(2025, 2, 1), amount: 111)

      get analysis_path, params: { year: 2025, month: 2 }

      expect(response.body).to include('111,00')
      expect(response.body).not_to include('999,00')
    end

    it 'offers the months with records of the selected year in the period popover' do
      travel_to Time.zone.local(2026, 5, 20, 10, 0)
      create(:earning, user: current_user, date: Date.new(2025, 3, 10))
      create(:expense, user: current_user, category: :fuel, date: Date.new(2025, 11, 10))

      get analysis_path(year: 2025)

      expect(response.body).to include('href="/analysis?month=3&year=2025"')
      expect(response.body).to include('href="/analysis?month=11&year=2025"')
      expect(response.body).not_to include('href="/analysis?month=4&year=2025"')
      expect(response.body).to include('href="/analysis?year=2026"')
    end
  end
end
