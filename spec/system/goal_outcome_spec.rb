require 'rails_helper'

RSpec.describe 'Goal outcome', type: :system, js: true do
  let(:current_user) { create(:user) }
  let(:goal) do
    create(:goal, user: current_user, kind: 'monthly', metric: 'profit', target_amount: 6_000,
                  period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
  end

  before do
    travel_to Time.zone.local(2026, 7, 2, 10, 0)
    create(:earning, user: current_user, date: Date.new(2026, 6, 13), amount: 3_000)
    create(:earning, user: current_user, date: Date.new(2026, 6, 27), amount: 3_120)
    login_as(current_user)
  end

  it 'opens the hit outcome from the goal reached notification with the confetti once on a phone' do
    create(:notification, user: current_user, kind: 'goal_reached',
                          data: { 'goal_id' => goal.id, 'period_start' => '2026-06-01', 'kind' => 'monthly',
                                  'metric' => 'profit', 'target' => 6_000.0, 'current' => 6_120.0 })

    visit notifications_path
    click_on 'Meta mensal batida! 🎯'

    expect(page).to have_current_path("/goals/#{goal.id}/outcomes/2026-06-01")
    expect(page).to have_text('Meta de junho batida!')
    expect(page).to have_text('+R$ 120,00 acima da meta · 102%')
    expect(page).to have_css('.dc-confetti', visible: :all)
    expect(page).to fit_the_phone_width

    visit goal_outcome_path(goal, '2026-06-01')

    expect(page).to have_text('Meta de junho batida!')
    expect(page).to have_no_css('.dc-confetti', visible: :all)
  end

  it 'goes back to the notifications from the outcome opened by a goal notification on a phone' do
    create(:notification, user: current_user, kind: 'goal_reached',
                          data: { 'goal_id' => goal.id, 'period_start' => '2026-06-01', 'kind' => 'monthly',
                                  'metric' => 'profit', 'target' => 6_000.0, 'current' => 6_120.0 })

    visit notifications_path
    click_on 'Meta mensal batida! 🎯'
    click_on I18n.t('goals.outcomes.show.back')

    expect(page).to have_current_path(notifications_path)
    expect(page).to fit_the_phone_width
  end

  it 'scrolls the hit outcome under a pinned header with the content inset from the edges on a short phone' do
    emulate_short_phone

    visit goal_outcome_path(goal, '2026-06-01')

    expect(box(find('a', text: 'Ver todas as metas'))['x']).to eq(20)
    expect(find('h1', text: 'Meta batida')).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end

  it 'keeps the footer link one card gap below the next step on a phone' do
    visit goal_outcome_path(goal, '2026-06-01')

    next_step = find('div.bg-blue-50', text: /Próximo passo/i)
    footer = find('a', text: 'Ver todas as metas')

    expect(box(footer)['top'] - box(next_step)['bottom']).to eq(16)
  end

  it 'hides the confetti under reduced motion on a phone' do
    emulate_reduced_motion('reduce')

    visit goal_outcome_path(goal, '2026-06-01')

    expect(computed('.dc-confetti', 'display')).to eq('none')
    expect(page).to fit_the_phone_width
  end

  it 'creates the next month goal from Subir a meta and then links to it on a phone' do
    visit goal_outcome_path(goal, '2026-06-01')

    expect(page).to have_text('Que tal R$ 6.500,00 em julho?')

    click_on 'Subir a meta'

    expect(page).to have_link('Ver meta de julho')
    expect(page).to have_no_button('Subir a meta')
    expect(Goal.find_by(user: current_user, kind: 'monthly', period_start: Date.new(2026, 7, 1)).target_amount).to eq(6_500)
    expect(page).to fit_the_phone_width
  end

  it 'keeps the target for the next month from Manter on a phone' do
    visit goal_outcome_path(goal, '2026-06-01')

    click_on "Manter R$\u00A06.000"

    expect(page).to have_link('Ver meta de julho')
    expect(Goal.find_by(user: current_user, kind: 'monthly', period_start: Date.new(2026, 7, 1)).target_amount).to eq(6_000)
    expect(page).to fit_the_phone_width
  end

  it 'lays the hero on seven columns beside the next step and journey on five on a desktop screen' do
    emulate_desktop_screen

    visit goal_outcome_path(goal, '2026-06-01')

    hero = find('div.border-emerald-200.border-2')
    next_step = find('div.bg-blue-50', text: /Próximo passo/i)
    journey = find('h3', text: 'Como você chegou lá').find(:xpath, '..')
    grid = hero.find(:xpath, '../..')

    expect(box(hero)['width']).to be_within(2).of(((box(grid)['width'] * 7) - 100) / 12)
    expect(box(next_step)['x']).to be > box(hero)['right']
    expect(box(next_step)['y']).to be < box(journey)['y']
    expect(page).to have_link('Ver metas', href: goals_path)
    expect(page).to have_text('Junho · 2026 · meta mensal de lucro líquido')
  end

  it 'ends the desktop topbar with the bell after Ver metas and a divider' do
    create(:notification, user: current_user)
    emulate_desktop_screen

    visit goal_outcome_path(goal, '2026-06-01')

    topbar = find('header', text: 'Meta batida')
    bell = topbar.find(:link, 'Notificações, 1 não lida')

    expect(topbar).to have_link('Ver metas', href: goals_path)
    expect(page.evaluate_script('document.elementFromPoint(245, 40).closest("header") !== null')).to be(true)
    expect(page.evaluate_script('document.elementFromPoint(1275, 40).closest("header") !== null')).to be(true)
    expect(bell).to have_css('span.bg-red-500', text: '1')
    expect(bell.evaluate_script('this.previousElementSibling.className')).to eq('w-px h-6 bg-slate-200')
  end
end
