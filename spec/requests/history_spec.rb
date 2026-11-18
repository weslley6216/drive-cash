require 'rails_helper'

RSpec.describe 'History', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  def feed_text
    Nokogiri::HTML(response.body).at_css('#history-feed').text
  end

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

      get history_path(year: 2025, types: %w[earnings])

      expect(feed_text).to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
      expect(feed_text).not_to include('Posto Shell')
    end

    it 'filters by unpaid expenses only' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', vendor: 'Posto X', paid: true)
      create(:expense, user: current_user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', vendor: 'Lanchonete', paid: false)

      get history_path(year: 2025, types: %w[expenses], unpaid: '1')

      expect(feed_text).to include('Lanchonete')
      expect(feed_text).not_to include('Posto X')
      expect(feed_text).not_to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
    end

    it 'filters by an expense category' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true)
      create(:expense, user: current_user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', vendor: 'Lanchonete', paid: true)

      get history_path(year: 2025, month: 6, categories: %w[fuel])

      expect(feed_text).to include('Posto Shell')
      expect(feed_text).not_to include('Lanchonete')
      expect(feed_text).not_to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
    end

    it 'narrows a category to the marked vendor, ignoring the same vendor of another user' do
      create(:expense, user: create(:user), date: Date.new(2025, 6, 10), amount: 999, category: 'fuel', vendor: 'Posto Shell', paid: true)
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true)
      create(:expense, user: current_user, date: Date.new(2025, 6, 12), amount: 70, category: 'fuel', vendor: 'Ipiranga', paid: true)

      get history_path(year: 2025, month: 6, categories: %w[fuel], vendors: { fuel: ['Posto Shell'] })

      expect(feed_text).to include('Posto Shell')
      expect(feed_text).not_to include('Ipiranga')
      expect(feed_text).not_to include('999,00')
    end

    it 'lists unpaid expenses in the default feed and sums them into the expenses tile only' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', vendor: 'Posto Paid', paid: true)
      create(:expense, user: current_user, date: Date.new(2025, 6, 12), amount: 30, category: 'meals', vendor: 'Lanchonete Unpaid', paid: false)

      get history_path(year: 2025)

      expect(response.body).to include('Posto Paid')
      expect(response.body).to include('Lanchonete Unpaid')
      expect(response.body).to include('110,00')
      expect(response.body).to include('120,00')
    end

    it 'searches by query case-insensitive' do
      create(:expense, user: current_user, date: Date.new(2025, 6, 10), amount: 80, category: 'fuel', vendor: 'Posto Florense', paid: true)
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 40, category: 'meals', vendor: 'Lanchonete', paid: true)

      get history_path(year: 2025, q: 'orense')

      expect(response.body).to include('Posto Florense')
      expect(response.body).not_to include('Lanchonete')
    end

    it 'marks unpaid expenses with the pending badge in the default feed' do
      create(:expense, user: current_user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', vendor: 'Lanchonete', paid: false)

      get history_path(year: 2025)

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

      get history_path(year: 2025, types: %w[expenses])

      expect(response.body).to include('200,00')
      expect(response.body).to include('80,00')
      expect(feed_text).not_to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
    end

    it 'describes a search without results under a type combination that matches no chip' do
      create(:earning, user: current_user, date: Date.current)

      get history_path(types: %w[earnings], unpaid: '1', q: 'nao-existe')

      expect(Nokogiri::HTML(response.body).text).to include(I18n.t('empty_states.history.description_query', query: 'nao-existe'))
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

    it 'ignores unknown slice values and the legacy filter param' do
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)

      get history_path(year: 2025, filter: 'fuel', types: %w[bogus], categories: %w[nonsense])

      expect(response.body).to include(I18n.t('activerecord.attributes.earning.platforms.uber'))
      expect(response.body).to include(I18n.t('activerecord.attributes.expense.categories.fuel'))
    end

    it 'falls back to the whole year when the month is out of the calendar range' do
      get history_path(year: 2026, month: 99)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('filter_component.year_all_months', year: 2026))
    end

    context 'with the twelve month range' do
      before do
        travel_to Time.zone.local(2026, 5, 22, 10, 0)
        create(:expense, user: current_user, date: Date.new(2025, 9, 10), amount: 189.9, category: 'insurance', paid: true)
      end

      it 'opens the twelve month mode of a single series' do
        get history_path(categories: %w[insurance], range: '12m')

        expect(response.body).to include('Seguro · por mês')
      end

      it 'ignores the twelve month range for a slice of two categories' do
        get history_path(categories: %w[insurance fuel], range: '12m')

        expect(response.body).not_to include('Seguro · por mês')
      end
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

  describe 'GET /history with page' do
    before do
      stub_const('History::FeedService::PER_PAGE', 1)
      create(:earning, user: current_user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
      create(:earning, user: current_user, date: Date.new(2025, 6, 12), amount: 100, platform: 'ifood')
    end

    it 'loads the newest day and links to the next page inside the feed frame' do
      get history_path(year: 2025, month: 6)

      load_more = Capybara.string(response.body).find_link(I18n.t('history.index.load_more'))
      expect(response.body).to include('day-2025-06-12')
      expect(response.body).not_to include('day-2025-06-10')
      expect(load_more[:href]).to eq(history_path(year: 2025, month: 6, page: 2))
      expect(load_more['data-turbo-frame']).to eq('history-feed')
    end

    it 'accumulates the requested page and drops the link on the last one' do
      get history_path(year: 2025, month: 6, page: 2)

      expect(response.body).to include('day-2025-06-12')
      expect(response.body).to include('day-2025-06-10')
      expect(response.body).not_to include(I18n.t('history.index.load_more'))
    end

    it 'falls back to the first page when the page is not a small positive number' do
      ['abc', '0', '-3', '9' * 200].each do |page|
        get history_path(year: 2025, month: 6, page: page)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.t('history.index.load_more'))
      end
    end

    it 'restarts from the first page while focusing a day' do
      get history_path(focus_day: '2025-06-12', page: 2)

      expect(response.body).to include(I18n.t('history.index.load_more'))
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

      get history_path(focus_day: '2025-06-11', q: 'nada', types: %w[earnings])

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

  describe 'GET /history with week' do
    before do
      create(:earning, user: current_user, date: Date.new(2025, 6, 29), amount: 999, platform: 'uber')
      create(:earning, user: current_user, date: Date.new(2025, 6, 30), amount: 200, platform: 'uber')
      create(:expense, user: current_user, date: Date.new(2025, 7, 5), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true)
      create(:earning, user: current_user, date: Date.new(2025, 7, 7), amount: 999, platform: 'uber')
    end

    it 'lists the monday to sunday records of a week across two months' do
      get history_path(week: '2025-07-02')

      expect(response.body).to include('day-2025-06-30')
      expect(response.body).to include('day-2025-07-05')
      expect(response.body).not_to include('day-2025-06-29')
      expect(response.body).not_to include('day-2025-07-07')
    end

    it 'shows the week chip that removes the week back to the month of the monday' do
      get history_path(week: '2025-07-02')

      page_html = Capybara.string(response.body)
      expect(page_html).to have_text('Semana de 30 de junho a 6 de julho')
      expect(page_html).to have_css("a[aria-label='Remover filtro da semana'][href='/history?month=6&year=2025']")
    end

    it 'swaps the search and the filters for the week chip' do
      get history_path(year: 2025, month: 6)
      month_html = Capybara.string(response.body)

      get history_path(week: '2025-07-02', q: 'nada', types: %w[earnings])
      week_html = Capybara.string(response.body)

      expect(month_html).to have_field('q')
      expect(week_html).to have_no_field('q')
      expect(week_html).to have_text('Posto Shell')
    end

    it 'keeps the week on the next page' do
      create_list(:earning, 25, user: current_user, date: Date.new(2025, 7, 3), platform: 'uber')
      create_list(:earning, 25, user: current_user, date: Date.new(2025, 7, 2), platform: 'uber')

      get history_path(week: '2025-07-02')

      expect(response.body).to match(/href="[^"]*page=2[^"]*week=2025-06-30/)
    end

    it 'discards a malformed or future week' do
      get history_path(week: 'ontem')
      malformed_body = response.body

      get history_path(week: (Date.current + 7).iso8601)

      expect(malformed_body).not_to include('Remover filtro da semana')
      expect(response.body).not_to include('Remover filtro da semana')
      expect(response).to have_http_status(:ok)
    end
  end
end
