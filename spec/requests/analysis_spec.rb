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

    it 'renders the four metric cards in a 2x2 grid' do
      create(:earning, user: current_user, date: Date.current, amount: 200, trips_count: 4)

      get analysis_path

      expect(response.body).to include(I18n.t('analysis.show_view.metrics.per_day'))
      expect(response.body).to include(I18n.t('analysis.show_view.metrics.per_trip'))
      expect(response.body).to include(I18n.t('analysis.show_view.metrics.per_hour'))
      expect(response.body).to include(I18n.t('analysis.show_view.metrics.margin'))
      expect(response.body).to include('grid-cols-2')
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
      create(:expense, user: current_user, date: Date.new(2024, 2, 1), amount: 100, category: 'fuel', paid: true)

      get analysis_path, params: { year: 2025, month: 2 }

      expect(response.body).to include('rounded-2xl')
      expect(response.body).to include('bg-amber-50')
      expect(response.body).to include('text-amber-900')
    end

    it 'filters by year and month query params' do
      create(:earning, user: current_user, date: Date.new(2024, 6, 1), amount: 999)
      create(:earning, user: current_user, date: Date.new(2025, 2, 1), amount: 111)

      get analysis_path, params: { year: 2025, month: 2 }

      expect(response.body).to include('111,00')
      expect(response.body).not_to include('999,00')
    end

    it 'does not include external chart scripts' do
      get analysis_path

      expect(response.body).not_to include('chart.js')
      expect(response.body).not_to include('recharts')
      expect(response.body).not_to include('d3.min')
    end
  end
end
