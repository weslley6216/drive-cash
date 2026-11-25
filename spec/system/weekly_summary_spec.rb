require 'rails_helper'

RSpec.describe 'Weekly summary', type: :system, js: true do
  let(:current_user) { create(:user) }
  let(:goal) do
    create(:goal, user: current_user, kind: 'weekly', metric: 'profit', target_amount: 1_100,
                  period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))
  end

  before do
    travel_to Time.zone.local(2026, 7, 14, 10, 0)

    (Date.new(2026, 7, 6)..Date.new(2026, 7, 10)).each do |date|
      create(:earning, user: current_user, date: date, amount: 200, trips_count: 8)
    end
    create(:expense, user: current_user, date: Date.new(2026, 7, 8), amount: 150, category: 'fuel', paid: true)
    create(:notification, user: current_user, kind: 'weekly_summary',
                          data: { 'week_start' => '2026-07-06', 'profit' => 850.0, 'trips' => 40 })

    login_as(current_user)
  end

  it 'opens the week from the weekly summary notification on a phone' do
    goal

    visit notifications_path

    click_on I18n.t('notifications.kinds.weekly_summary.title')

    expect(page).to have_current_path('/weekly_summaries/2026-07-06')
    expect(page).to have_text('6 a 12 de julho')
    expect(page).to have_text('+R$ 1.000,00 receitas')
    expect(page).to have_text('Meta da semana')
    expect(page).to have_text('Sábado e domingo sem lançamentos.')
    expect(page).to have_text('Onde foi o dinheiro')
    expect(page).to fit_the_phone_width
  end

  it 'walks back and forth between weeks on a phone' do
    visit weekly_summary_path('2026-07-13')

    expect(page).to have_css("button[disabled][aria-label='Próxima semana']")

    find("a[aria-label='Semana anterior']").click

    expect(page).to have_current_path('/weekly_summaries/2026-07-06')
    expect(page).to have_text('6 a 12 de julho')

    find("a[aria-label='Próxima semana']").click

    expect(page).to have_current_path('/weekly_summaries/2026-07-13')
    expect(page).to fit_the_phone_width
  end

  it 'opens the goal outcome from the goal block and goes back to the week on a phone' do
    goal

    visit weekly_summary_path('2026-07-06')

    expect(box(find_link('Ver resultado da meta'))['width']).to be < 200

    click_on 'Ver resultado da meta'

    expect(page).to have_current_path("/goals/#{goal.id}/outcomes/2026-07-06", ignore_query: true)
    expect(page).to fit_the_phone_width

    click_on I18n.t('goals.outcomes.show.back')

    expect(page).to have_current_path('/weekly_summaries/2026-07-06')
  end

  it 'opens the entries of the week in the history on a phone' do
    visit weekly_summary_path('2026-07-06')

    click_on 'Ver lançamentos da semana'

    expect(page).to have_current_path('/history?week=2026-07-06')
    expect(page).to have_text('Semana de 6 a 12 de julho')
    expect(page).to fit_the_phone_width
  end

  it 'goes to the analysis of the month from the secondary link on a phone' do
    visit weekly_summary_path('2026-07-06')

    click_on 'Análise de julho →'

    expect(page).to have_current_path('/analysis?month=7&year=2026')
  end

  it 'keeps the weekly summary header still while the week scrolls on a phone' do
    emulate_short_phone

    visit weekly_summary_path(week_start: '2026-07-06')

    expect(find('h1', text: I18n.t('weekly_summaries.show.title'))).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end

  it 'lines the week cards up with the 20px prototype gutter on a phone' do
    visit weekly_summary_path('2026-07-06')

    profit_card = find('#screen-content .rounded-xl', text: I18n.t('weekly_summaries.show.profit'))

    expect(box(profit_card)['x'].round).to eq(20)
    expect(box(profit_card)['right'].round).to eq(370)
    expect(page).to fit_the_phone_width
  end

  it 'keeps the 16px prototype gap between the last card and the history CTA on a phone' do
    visit weekly_summary_path('2026-07-06')

    last_card = find('#screen-content .rounded-xl', text: 'Onde foi o dinheiro')
    cta = find_link('Ver lançamentos da semana')

    expect(box(cta)['y'] - box(last_card)['bottom']).to be_within(0.5).of(16)
    expect(page).to fit_the_phone_width
  end

  it 'lays the hero and the goal on five columns beside the bars on a desktop screen' do
    goal
    emulate_desktop_screen

    visit weekly_summary_path('2026-07-06')

    hero = find('#screen-content .rounded-xl', text: I18n.t('weekly_summaries.show.profit'))
    bars = find('#screen-content .rounded-xl', text: I18n.t('weekly_summaries.show.daily_title'))
    goal_card = find('#screen-content .rounded-xl', text: 'Meta da semana')
    grid = hero.find(:xpath, '../..')
    track = find('[data-weekday="0"]').find(:xpath, '..')
    topbar = find('#screen-header h1', text: 'Sua semana').find(:xpath, '../..')

    expect(box(topbar)['y']).to eq(0)
    expect(box(hero)['y'] - box(topbar)['bottom']).to be_within(1).of(32)
    expect(box(hero)['width']).to be_within(2).of(((box(grid)['width'] * 5) - 140) / 12)
    expect(box(goal_card)['y']).to be > box(hero)['bottom']
    expect(box(bars)['x']).to be > box(hero)['right']
    expect(box(track)['height']).to be_within(1).of(150)
    expect(page).to have_text('6 a 12 de julho de 2026')
    expect(page).to have_link('Ver lançamentos da semana', href: '/history?week=2026-07-06')
    expect(page).to have_link('Análise de julho →', href: '/analysis?month=7&year=2026')
    expect(page).to have_no_css("[aria-label='#{I18n.t('weekly_summaries.show.back')}']")
  end

  it 'ends the desktop topbar with the bell after the week nav, the CTA and a divider' do
    emulate_desktop_screen

    visit weekly_summary_path('2026-07-06')

    topbar = find('header', text: 'Sua semana')
    bell = topbar.find(:link, 'Notificações, 1 não lida')

    expect(topbar).to have_link('Semana anterior', href: '/weekly_summaries/2026-06-29')
    expect(topbar).to have_link('Ver lançamentos da semana', href: '/history?week=2026-07-06')
    expect(bell).to have_css('span.bg-red-500', text: '1')
    expect(bell.evaluate_script('this.previousElementSibling.className')).to eq('w-px h-6 bg-slate-200')
  end
end
