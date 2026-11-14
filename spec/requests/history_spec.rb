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
      create(:expense, user: current_user, date: Date.new(2025, 6, 12), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true)

      get history_path(year: 2025)

      day12 = response.body.index('day-2025-06-12')
      day10 = response.body.index('day-2025-06-10')
      expect(day12).not_to be_nil
      expect(day10).not_to be_nil
      expect(day12).to be < day10
    end

    it 'renders each day group with earnings and expenses totals' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 10), amount: 80, category: 'fuel', paid: true)

      get history_path(year: 2025)

      expect(response.body).to include('+R$ 200<')
      expect(response.body).to include('−R$ 80<')
    end

    it 'filters by earnings only' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true)

      get history_path(year: 2025, filter: 'earnings')

      expect(response.body).to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
      expect(response.body).not_to include('Posto Shell')
    end

    it 'filters by unpaid expenses only' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', vendor: 'Posto X', paid: true)
      create(:expense, user: current_user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', vendor: 'Lanchonete', paid: false)

      get history_path(year: 2025, filter: 'unpaid')

      expect(response.body).to include('Lanchonete')
      expect(response.body).not_to include('Posto X')
      expect(response.body).not_to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
    end

    it 'filters by an expense category and marks its chip active' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true)
      create(:expense, user: current_user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', vendor: 'Lanchonete', paid: true)

      get history_path(year: 2025, month: 6, filter: 'fuel')

      expect(response.body).to include('Posto Shell')
      expect(response.body).not_to include('Lanchonete')
      expect(response.body).not_to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
      active_chip = Capybara.string(response.body).find('a.bg-slate-800.text-white', text: I18n.t('activerecord.attributes.expense.categories.fuel'), exact_text: true)
      expect(active_chip[:href]).to eq(history_path(filter: 'fuel', year: 2025, month: 6))
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
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)

      get history_path(year: 2025, filter: 'expenses')

      expect(response.body).to include('200,00')
      expect(response.body).to include('80,00')
      expect(response.body).not_to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
    end

    it 'renders the FAB positioned above the bottom nav' do
      get history_path

      expect(response.body).to include('fixed bottom-above-nav right-5')
    end

    it 'renders the no-results empty state when a filter matches nothing' do
      create(:earning, user: current_user, date: Date.current)

      get history_path(q: 'nao-existe-nada-assim')

      expect(response.body).to include(I18n.t('empty_states.history.title'))
      expect(response.body).to include(I18n.t('empty_states.history.cta'))
    end

    it 'renders the blank empty state when the period has no records' do
      get history_path

      expect(response.body).to include(I18n.t('empty_states.history.blank.title'))
      expect(response.body).to include(I18n.t('empty_states.history.blank.cta'))
    end

    it 'renders the feed when records exist' do
      create(:earning, user: current_user, date: Date.current)

      get history_path

      expect(response.body).not_to include(I18n.t('empty_states.history.blank.title'))
    end

    it 'wires a highlight controller on the phone list and on the desktop table' do
      create(:earning, user: current_user, date: Date.current)

      get history_path

      expect(response.body.scan('data-controller="highlight"').size).to eq(2)
      expect(response.body).to include('ring-amber-400')
      expect(response.body).to include('outline-amber-400')
    end

    it 'falls back to filter "all" when the param is invalid' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)

      get history_path(year: 2025, filter: 'nonsense')

      expect(response.body).to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
      expect(response.body).to include(I18n.t('activerecord.attributes.expense.categories.fuel'))
    end

    it 'falls back to the whole year when the month is out of the calendar range' do
      get history_path(year: 2026, month: 99)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('filter_component.year_all_months', year: 2026))
    end

    it 'offers the current month in the period popover even when the user has no records' do
      get history_path

      expect(response.body).to include(%(href="/history?month=#{Date.current.month}&year=#{Date.current.year}"))
    end

    it 'points the previous-year arrow at the last earlier year with records' do
      travel_to Time.zone.local(2026, 5, 22, 10, 0)
      create(:earning, user: current_user, date: Date.new(2023, 5, 1), amount: 100, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2024, 7, 1), amount: 50, category: 'fuel', paid: true)

      get history_path

      expect(response.body).to include('href="/history?year=2024"')
      expect(response.body).to include(%(aria-label="#{I18n.t('filter_component.previous_year')}"))
    end
  end

  describe 'GET /history with focus_day' do
    it 'opens the period of focus_day with the empty day marker' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')

      get history_path(focus_day: '2025-06-11')

      expect(response.body).to include('id="day-2025-06-11"')
      expect(response.body).to include(I18n.t('history.index.gap_day.title'))
      expect(response.body).to include('day-2025-06-10')
    end

    it 'ignores the search and the chip filter while focusing a day' do
      create(:expense, user: current_user, date: Date.new(2025, 6, 12), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true)

      get history_path(focus_day: '2025-06-11', q: 'nada', filter: 'earnings')

      expect(response.body).to include('Posto Shell')
      expect(response.body).to include(I18n.t('history.index.gap_day.title'))
    end

    it 'shows no empty days without focus_day' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:earning, user: current_user, date: Date.new(2025, 6, 12), amount: 100, platform: 'uber')

      get history_path(year: 2025)

      expect(response.body).not_to include('day-2025-06-11')
      expect(response.body).not_to include(I18n.t('history.index.gap_day.title'))
    end

    it 'discards a malformed focus_day' do
      get history_path(focus_day: 'ontem')

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(I18n.t('history.index.gap_day.title'))
    end

    it 'discards a focus_day longer than the date parser accepts' do
      get history_path(focus_day: '2' * 200)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(I18n.t('history.index.gap_day.title'))
    end

    it 'discards a focus_day in the future' do
      get history_path(focus_day: (Date.current + 1).iso8601)

      expect(response.body).not_to include(I18n.t('history.index.gap_day.title'))
    end
  end
end
