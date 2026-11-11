require 'rails_helper'

RSpec.describe 'Weekly summary', type: :system, js: true do
  let(:current_user) { create(:user) }

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
    visit notifications_path

    click_on I18n.t('notifications.kinds.weekly_summary.title')

    expect(page).to have_current_path('/weekly_summaries/2026-07-06')
    expect(page).to have_text('Sua semana')
    expect(page).to have_text('6 a 12 de julho')
    expect(page).to have_text('Lucro por dia')
    expect(page).to have_text('Maior gasto')
    expect(page).to fit_the_phone_width
  end

  it 'goes to the analysis of the month from the CTA on a phone' do
    visit weekly_summary_path('2026-07-06')

    click_on 'Ver análise completa'

    expect(page).to have_current_path('/analysis?month=7&year=2026')
  end

  it 'centers the week in a narrow column on a desktop screen' do
    emulate_desktop_screen

    visit weekly_summary_path('2026-07-06')

    expect(page).to have_css('.max-w-2xl', text: 'Sua semana')
    expect(page).to have_no_css("[aria-label='#{I18n.t('weekly_summaries.show.back')}']")
  end
end
