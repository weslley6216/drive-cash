require 'rails_helper'

RSpec.describe 'Goals', type: :system, js: true do
  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 5, 22, 10, 0)
    login_as(current_user)
  end

  def card_of(title)
    find('p', text: title, exact_text: true, match: :first).find(:xpath, 'ancestor::div[contains(@class, "rounded-xl")][1]')
  end

  def seed_goals
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
    seed_goals

    visit goals_path

    monday_bar = find('[data-day-bar="2026-05-18"]')
    hit_area = find('[data-new-goal-button] span')

    expect(box(monday_bar)['height'].round).to eq(47)
    expect(box(hit_area)['height']).to be >= 44
    expect(page).to have_text(I18n.t('goals.index.annual.months_left', count: 7))
    expect(page).to fit_the_phone_width
  end

  it 'fits the phone width in dark mode with a five digit monthly value' do
    seed_goals
    emulate_color_scheme('dark')

    visit goals_path

    expect(page).to have_text('R$ 13.595,67')
    expect(page).to fit_the_phone_width
  end

  it 'shows the empty block without the past goals section on a phone' do
    visit goals_path

    expect(page).to have_link(I18n.t('empty_states.goals.cta'))
    expect(page).to have_no_text(I18n.t('goals.index.past_goals.title'))
    expect(page).to fit_the_phone_width
  end

  it 'spreads the hero across the row and lines up the weekly, annual and achievements cards on a desktop screen' do
    seed_goals
    emulate_desktop_screen

    visit goals_path

    hero = find('div.border-blue-200')
    weekly = card_of(I18n.t('goals.index.weekly.label'))
    annual = card_of(I18n.t('goals.index.annual.label_desktop'))
    achievements = find('h3', text: I18n.t('goals.index.achievements.title')).find(:xpath, '../..')

    expect(box(hero)['width']).to be_within(1).of(box(weekly)['width'] + box(annual)['width'] + box(achievements)['width'] + 40)
    expect([weekly, annual, achievements].map { |card| box(card)['y'].round }.uniq.size).to eq(1)
    expect(page).to have_link(I18n.t('goals.index.new_goal'), href: new_goal_path)
  end
end
