require 'rails_helper'

RSpec.describe 'Active nav tab', type: :system, js: true do
  let(:current_user) { create(:user, name: 'Weslley Campos') }

  before do
    travel_to Time.zone.local(2026, 5, 22, 10, 0)
    login_as(current_user)
  end

  context 'with a past goal' do
    let(:goal) do
      create(:goal, user: current_user, kind: 'monthly', target_amount: 1_000,
                    period_start: Date.new(2026, 4, 1), period_end: Date.new(2026, 4, 30))
    end

    before { create(:earning, user: current_user, amount: 1_200, date: Date.new(2026, 4, 10)) }

    it 'keeps Metas lit on the bottom nav after opening a past goal outcome on a phone' do
      goal
      visit root_path
      find('#bottom-nav a', text: 'Metas').click
      find('a', text: 'Abril 2026').click

      expect(page).to have_current_path("/goals/#{goal.id}/outcomes/2026-04-01", ignore_query: true)
      expect(page).to have_css('#bottom-nav a.text-blue-600', text: 'Metas')
      expect(page).to have_css('#bottom-nav a.text-slate-400', text: 'Início')
      expect(page).to fit_the_phone_width
    end

    it 'keeps Metas lit on the sidebar after opening a past goal outcome on a desktop screen' do
      emulate_desktop_screen
      goal
      visit root_path
      find('#sidebar-nav a', text: 'Metas').click
      find('a', text: 'Abril 2026').click

      expect(page).to have_current_path("/goals/#{goal.id}/outcomes/2026-04-01", ignore_query: true)
      expect(page).to have_css('#sidebar-nav a.bg-blue-50', text: 'Metas')
      expect(page).to have_css('#sidebar-nav a.text-slate-600', text: 'Início')
    end

    it 'lights Metas when the outcome is the first page loaded on a phone' do
      visit goal_outcome_path(goal, '2026-04-01')

      expect(page).to have_css('#bottom-nav a.text-blue-600', text: 'Metas')
      expect(page).to fit_the_phone_width
    end
  end

  it 'lights Análise for the week summary opened from the Home on a phone' do
    visit root_path
    visit weekly_summary_path('2026-05-11')

    expect(page).to have_css('#bottom-nav a.text-blue-600', text: 'Análise')
    expect(page).to have_css('#bottom-nav a.text-slate-400', text: 'Início')
    expect(page).to fit_the_phone_width
  end

  it 'lights Análise on the sidebar for the week summary on a desktop screen' do
    emulate_desktop_screen

    visit weekly_summary_path('2026-05-11')

    expect(page).to have_css('#sidebar-nav a.bg-blue-50', text: 'Análise')
    expect(page).to have_css('#sidebar-nav a.text-slate-600', text: 'Início')
  end

  it 'keeps the account footer lit on the notifications and turns it off on Metas on a desktop screen' do
    emulate_desktop_screen
    visit root_path
    find('#sidebar-nav a[href="/account"]').click
    click_on I18n.t('account.items.notifications.label')

    expect(page).to have_current_path(notifications_path, ignore_query: true)
    expect(page).to have_css('#sidebar-nav a.bg-blue-50[href="/account"]')

    find('#sidebar-nav a', text: 'Metas').click

    expect(page).to have_css('#sidebar-nav a.bg-blue-50', text: 'Metas')
    expect(page).to have_css('#sidebar-nav a.hover\:bg-slate-50[href="/account"]')
    expect(page).to have_no_css('#sidebar-nav a.bg-blue-50[href="/account"]')
  end
end
