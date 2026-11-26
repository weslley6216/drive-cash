require 'rails_helper'

RSpec.describe 'Goal missed outcome', type: :system, js: true do
  let(:current_user) { create(:user) }
  let(:goal) do
    create(:goal, user: current_user, kind: 'weekly', metric: 'profit', target_amount: 1_100,
                  period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))
  end

  before do
    travel_to Time.zone.local(2026, 7, 13, 10, 0)
    create(:earning, user: current_user, date: Date.new(2026, 7, 6), amount: 250)
    create(:earning, user: current_user, date: Date.new(2026, 7, 8), amount: 300)
    create(:expense, user: current_user, date: Date.new(2026, 7, 8), amount: 32, paid: true)
    create(:earning, user: current_user, date: Date.new(2026, 7, 10), amount: 270)
    create(:earning, user: current_user, date: Date.new(2026, 7, 11), amount: 202)
    login_as(current_user)
  end

  it 'opens the missed outcome from the goal missed notification without confetti on a phone' do
    create(:notification, user: current_user, kind: 'goal_missed',
                          data: { 'goal_id' => goal.id, 'period_start' => '2026-07-06', 'kind' => 'weekly',
                                  'metric' => 'profit', 'target' => 1_100.0, 'current' => 990.0 })

    visit notifications_path
    click_on 'Meta da semana: faltou pouco'

    expect(page).to have_current_path("/goals/#{goal.id}/outcomes/2026-07-06")
    expect(page).to have_text('Não foi dessa vez, mas foi perto')
    expect(page).to have_text('Para esta semana: R$ 275,00 por dia em 4 dias de trabalho.')
    expect(page).to have_no_css('.dc-confetti', visible: :all)
    expect(page).to fit_the_phone_width
  end

  it 'scrolls the missed outcome under a pinned header with the content inset from the edges on a short phone' do
    emulate_short_phone

    visit goal_outcome_path(goal, '2026-07-06')

    expect(box(find('a', text: 'Ver lançamentos da semana'))['x']).to eq(20)
    expect(find('h1', text: 'Resultado da meta')).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end

  it 'keeps the footer link one card gap below the next step on a phone' do
    visit goal_outcome_path(goal, '2026-07-06')

    next_step = find('div.bg-blue-50', text: /Próximo passo/i)
    footer = find('a', text: 'Ver lançamentos da semana')

    expect(box(footer)['top'] - box(next_step)['bottom']).to eq(16)
  end

  it 'adjusts the next week goal to the recent average on a phone' do
    visit goal_outcome_path(goal, '2026-07-06')

    click_on "Ajustar para R$\u00A0990"

    expect(page).to have_link('Ver meta de 13/jul a 19/jul')
    expect(Goal.find_by(user: current_user, kind: 'weekly', period_start: Date.new(2026, 7, 13)).target_amount).to eq(990)
    expect(page).to fit_the_phone_width
  end

  it 'keeps the target for the next week from Manter a meta on a phone' do
    visit goal_outcome_path(goal, '2026-07-06')

    click_on 'Manter a meta'

    expect(page).to have_link('Ver meta de 13/jul a 19/jul')
    expect(Goal.find_by(user: current_user, kind: 'weekly', period_start: Date.new(2026, 7, 13)).target_amount).to eq(1_100)
  end

  it 'opens the entries of the week from the footer on a phone' do
    visit goal_outcome_path(goal, '2026-07-06')

    click_on 'Ver lançamentos da semana'

    expect(page).to have_current_path(history_path(week: '2026-07-06'))
    expect(page).to have_text('Semana de 6 a 12 de julho')
    expect(page).to fit_the_phone_width
  end

  it 'lays the hero on seven columns beside the next step above what went well on a desktop screen' do
    emulate_desktop_screen

    visit goal_outcome_path(goal, '2026-07-06')

    hero = find('div.border-slate-100.shadow-sm', text: 'Não foi dessa vez')
    next_step = find('div.bg-blue-50', text: /Próximo passo/i)
    went_well = find('h3', text: 'O que foi bem').find(:xpath, '..')
    grid = hero.find(:xpath, '../..')

    expect(box(hero)['width']).to be_within(2).of(((box(grid)['width'] * 7) - 100) / 12)
    expect(box(next_step)['x']).to be > box(hero)['right']
    expect(box(next_step)['y']).to be < box(went_well)['y']
    expect(page).to have_link('Ver lançamentos da semana', href: history_path(week: '2026-07-06'))
    expect(page).to have_text('06/jul a 12/jul · 2026 · meta semanal de lucro líquido')
  end

  it 'ends the desktop topbar with the bell after the entries link and a divider' do
    create(:notification, user: current_user)
    emulate_desktop_screen

    visit goal_outcome_path(goal, '2026-07-06')

    topbar = find('header', text: 'Resultado da meta')
    bell = topbar.find(:link, 'Notificações, 1 não lida')

    expect(topbar).to have_link('Ver lançamentos da semana', href: history_path(week: '2026-07-06'))
    expect(page.evaluate_script('document.elementFromPoint(245, 40).closest("header") !== null')).to be(true)
    expect(page.evaluate_script('document.elementFromPoint(1275, 40).closest("header") !== null')).to be(true)
    expect(bell).to have_css('span.bg-red-500', text: '1')
    expect(bell.evaluate_script('this.previousElementSibling.className')).to eq('w-px h-6 bg-slate-200')
  end
end
