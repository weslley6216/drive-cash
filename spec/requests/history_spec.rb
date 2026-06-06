require 'rails_helper'

RSpec.describe 'History', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  describe 'GET /history' do
    it 'returns 200' do
      get history_path

      expect(response).to have_http_status(:ok)
    end

    it 'highlights the history tab in the bottom nav' do
      get history_path

      expect(response.body).to include(I18n.t('bottom_nav_component.tabs.history'))
      expect(response.body).to include('text-blue-600')
    end

    it 'renders all entries of the year grouped by day in desc order' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber', trips_count: 3)
      create(:expense, user: current_user, date: Date.new(2025, 6, 12), amount: 80,  category: 'fuel', vendor: 'Posto Shell', paid: true)

      get history_path(year: 2025)

      day12 = response.body.index('day-2025-06-12')
      day10 = response.body.index('day-2025-06-10')
      expect(day12).not_to be_nil
      expect(day10).not_to be_nil
      expect(day12).to be < day10
    end

    it 'renders each day group with earnings and expenses totals' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 10), amount: 80,  category: 'fuel', paid: true)

      get history_path(year: 2025)

      expect(response.body).to include('+ R$')
      expect(response.body).to include('− R$')
      expect(response.body).to include('200,00')
      expect(response.body).to include('80,00')
    end

    it 'filters by earnings only' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80,  category: 'fuel', vendor: 'Posto Shell', paid: true)

      get history_path(year: 2025, filter: 'earnings')

      expect(response.body).to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
      expect(response.body).not_to include('Posto Shell')
    end

    it 'filters by unpaid expenses only' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80,  category: 'fuel', vendor: 'Posto X', paid: true)
      create(:expense, user: current_user, date: Date.new(2025, 6, 12), amount: 40,  category: 'meals', vendor: 'Lanchonete', paid: false)

      get history_path(year: 2025, filter: 'unpaid')

      expect(response.body).to include('Lanchonete')
      expect(response.body).not_to include('Posto X')
      expect(response.body).not_to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
    end

    it 'excludes unpaid expenses from the default feed and net summary' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', vendor: 'Posto Paid', paid: true)
      create(:expense, user: current_user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', vendor: 'Lanchonete Unpaid', paid: false)

      get history_path(year: 2025)

      expect(response.body).to include('Posto Paid')
      expect(response.body).not_to include('Lanchonete Unpaid')
      expect(response.body).to include('120,00')
    end

    it 'searches by query case-insensitive' do
      create(:expense, user: current_user, date: Date.new(2025, 6, 10), amount: 80, category: 'fuel', vendor: 'Posto Florense', paid: true)
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 40, category: 'meals', vendor: 'Lanchonete', paid: true)

      get history_path(year: 2025, q: 'orense')

      expect(response.body).to include('Posto Florense')
      expect(response.body).not_to include('Lanchonete')
    end

    it 'renders the pending badge only inside the unpaid filter' do
      create(:expense, user: current_user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', vendor: 'Lanchonete', paid: false)

      get history_path(year: 2025)

      expect(response.body).not_to include(I18n.t('history.index.day_group.unpaid_badge'))

      get history_path(year: 2025, filter: 'unpaid')

      expect(response.body).to include(I18n.t('history.index.day_group.unpaid_badge'))
      expect(response.body).to include('bg-amber-100')
    end

    it 'links each entry to its edit form inside the modal turbo frame' do
      earning = create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      expense = create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)

      get history_path(year: 2025)

      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include("/earnings/#{earning.id}/edit")
      expect(response.body).to include("/expenses/#{expense.id}/edit")
      expect(response.body).to include('data-turbo-frame="modal"')
    end

    it 'summary always shows full-period totals regardless of chip filter' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80,  category: 'fuel', paid: true)

      get history_path(year: 2025, filter: 'expenses')

      expect(response.body).to include('200,00')
      expect(response.body).to include('80,00')
      expect(response.body).not_to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
    end

    it 'renders the FAB positioned above the bottom nav' do
      get history_path

      expect(response.body).to include('fixed bottom-24 right-6')
    end

    it 'renders the empty state when there are no records' do
      get history_path(year: 2020)

      expect(response.body).to include(I18n.t('history.index.empty'))
    end

    it 'falls back to filter "all" when the param is invalid' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80,  category: 'fuel', paid: true)

      get history_path(year: 2025, filter: 'nonsense')

      expect(response.body).to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
      expect(response.body).to include(I18n.t('activerecord.attributes.expense.categories.fuel'))
    end

    it 'always includes the current year in the year selector even when the user has no records' do
      get history_path

      expect(response.body).to include(%(value="#{Date.current.year}"))
    end

    it 'lists historical years from earnings and expenses in descending order' do
      create(:earning, user: current_user, date: Date.new(2023, 5, 1), amount: 100, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2024, 7, 1), amount: 50, category: 'fuel', paid: true)

      get history_path

      idx_2024 = response.body.index(%(value="2024"))
      idx_2023 = response.body.index(%(value="2023"))

      expect(idx_2024).not_to be_nil
      expect(idx_2023).not_to be_nil
      expect(idx_2024).to be < idx_2023
    end
  end
end
