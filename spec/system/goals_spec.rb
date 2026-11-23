require 'rails_helper'

RSpec.describe 'Goals', type: :system, js: true do
  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 5, 22, 10, 0)
    login_as(current_user)
  end

  context 'with the month, week and year goals running' do
    before do
      (18..22).each { |day| create(:earning, user: current_user, amount: 250, date: Date.new(2026, 5, day)) }
      create(:earning, user: current_user, amount: 12_345.67, date: Date.new(2026, 5, 2))
      create(:goal, user: current_user, kind: 'monthly', target_amount: 20_000,
             period_start: Date.new(2026, 5, 1), period_end: Date.new(2026, 5, 31))
      create(:goal, user: current_user, kind: 'weekly', metric: 'earnings', target_amount: 1600,
             period_start: Date.new(2026, 5, 18), period_end: Date.new(2026, 5, 24))
      create(:goal, user: current_user, kind: 'annual', target_amount: 80_000,
             period_start: Date.new(2026, 1, 1), period_end: Date.new(2026, 12, 31))
    end

    it 'scales the weekly bars to a daily share of the target and keeps a 44px new goal target on a phone' do
      visit goals_path

      monday_bar = find('[data-day-bar="2026-05-18"]')
      hit_area = find('[data-new-goal-button] span')

      expect(box(monday_bar)['height'].round).to eq(47)
      expect(box(hit_area)['height']).to be >= 44
      expect(page).to have_text(I18n.t('goals.index.annual.months_left', count: 7))
      expect(page).to fit_the_phone_width
    end

    it 'keeps the goals header still while the goal cards scroll on a phone' do
      emulate_short_phone

      visit goals_path

      expect(find('h1', text: I18n.t('goals.index.title'))).to stay_pinned_while_the_content_scrolls
      expect(page).to fit_the_phone_width
    end

    it 'fits the phone width in dark mode with a five digit monthly value' do
      emulate_color_scheme('dark')

      visit goals_path

      expect(page).to have_text('R$ 13.595,67')
      expect(page).to fit_the_phone_width
    end

    it 'spreads the hero across the row and lines up the weekly, annual and achievements cards on a desktop screen' do
      emulate_desktop_screen

      visit goals_path

      hero = find('div.border-blue-200')
      weekly = find('p', text: I18n.t('goals.index.weekly.label'), exact_text: true, match: :first)
        .find(:xpath, 'ancestor::div[contains(@class, "rounded-xl")][1]')
      annual = find('p', text: I18n.t('goals.index.annual.label_desktop'), exact_text: true, match: :first)
        .find(:xpath, 'ancestor::div[contains(@class, "rounded-xl")][1]')
      achievements = find('h3', text: I18n.t('goals.index.achievements.title')).find(:xpath, '../..')

      expect(box(hero)['width']).to be_within(1).of(box(weekly)['width'] + box(annual)['width'] + box(achievements)['width'] + 40)
      expect([weekly, annual, achievements].map { |card| box(card)['y'].round }.uniq.size).to eq(1)
      expect(page).to have_link(I18n.t('goals.index.new_goal'), href: new_goal_path)
    end

    context 'with April hit and a seven day streak' do
      before do
        (16..17).each { |day| create(:earning, user: current_user, amount: 250, date: Date.new(2026, 5, day)) }
        create(:goal, user: current_user, kind: 'monthly', target_amount: 5000,
               period_start: Date.new(2026, 4, 1), period_end: Date.new(2026, 4, 30))
        create(:earning, user: current_user, amount: 5400, date: Date.new(2026, 4, 10))
      end

      it 'shows the short achievement labels with a rounded thousands value on a phone' do
        visit goals_path

        expect(page).to have_text('Sequência 7 dias')
        expect(page).to have_text('Meta de Abril')
        expect(page).to have_text('Melhor dia: R$ 12.346')
        expect(page).to have_no_text('Sequência de 7 dias trabalhando')
        expect(page).to have_no_text('Meta de Abril batida (108%)')
        expect(page).to fit_the_phone_width
      end

      it 'shows the long achievement sentences on a desktop screen' do
        emulate_desktop_screen

        visit goals_path

        expect(page).to have_text('Sequência de 7 dias trabalhando')
        expect(page).to have_text('Meta de Abril batida (108%)')
        expect(page).to have_text('Melhor dia: R$ 12.346 em 02/mai')
        expect(page).to have_no_text('Sequência 7 dias')
      end
    end
  end

  it 'shows the empty block without the past goals section on a phone' do
    visit goals_path

    expect(page).to have_link(I18n.t('empty_states.goals.cta'))
    expect(page).to have_no_text(I18n.t('goals.index.past_goals.title'))
    expect(page).to fit_the_phone_width
  end

  it 'suggests a realistic target below the empty block on a phone' do
    create(:earning, user: current_user, amount: 6000, date: Date.new(2026, 2, 10))
    create(:earning, user: current_user, amount: 6300, date: Date.new(2026, 3, 10))
    create(:earning, user: current_user, amount: 6441, date: Date.new(2026, 4, 10))

    visit goals_path

    expect(page).to have_text(I18n.t('goals.index.suggestion.label').upcase)
    expect(page).to have_text('R$ 6.200,00')
    expect(page).to fit_the_phone_width
  end

  it 'ends the topbar with the bell after the new goal link and a divider on a desktop screen' do
    create(:notification, user: current_user)
    emulate_desktop_screen

    visit goals_path

    topbar = find('header', text: I18n.t('goals.index.title'))
    bell = topbar.find(:link, 'Notificações, 1 não lida')

    expect(topbar).to have_link(I18n.t('goals.index.new_goal'), href: new_goal_path)
    expect(bell).to have_css('span.bg-red-500', text: '1')
    expect(bell.evaluate_script('this.previousElementSibling.className')).to eq('w-px h-6 bg-slate-200')
  end

  it 'opens the outcome of a missed and of a hit past goal from Metas anteriores on a phone' do
    missed = create(:goal, user: current_user, kind: 'monthly', target_amount: 1_000,
                    period_start: Date.new(2026, 3, 1), period_end: Date.new(2026, 3, 31))
    hit = create(:goal, user: current_user, kind: 'monthly', target_amount: 1_000,
                 period_start: Date.new(2026, 4, 1), period_end: Date.new(2026, 4, 30))
    create(:earning, user: current_user, amount: 500, date: Date.new(2026, 3, 10))
    create(:earning, user: current_user, amount: 1_200, date: Date.new(2026, 4, 10))

    visit goals_path
    find('a', text: 'Março 2026').click

    expect(page).to have_current_path("/goals/#{missed.id}/outcomes/2026-03-01")
    expect(page).to have_text('Não foi dessa vez')
    expect(page).to fit_the_phone_width

    visit goals_path
    find('a', text: 'Abril 2026').click

    expect(page).to have_current_path("/goals/#{hit.id}/outcomes/2026-04-01")
    expect(page).to have_text('Meta de abril batida!')
    expect(page).to fit_the_phone_width
  end
end
