require 'rails_helper'

RSpec.describe 'Home detail modal', type: :system, js: true do
  let(:current_user) { create(:user) }

  before do
    travel_to Time.zone.local(2026, 5, 22, 10, 0)
    create(:earning, user: current_user, date: Date.new(2026, 5, 22), amount: 245, platform: 'uber')
    create(:earning, user: current_user, date: Date.new(2026, 1, 12), amount: 4830.90, platform: 'nine_nine')
    create(:expense, user: current_user, date: Date.new(2026, 5, 22), amount: 80, category: 'fuel', vendor: 'Posto Orense')
    login_as(current_user)
  end

  def modal_card
    find('turbo-frame#modal [data-controller="modal"] > div')
  end

  it 'opens the annual earnings, drills into a month and comes back through the footer arrow on a phone' do
    visit root_path

    find('#stats_grid a', text: /\A#{I18n.t('dashboard.index_view.stats.earnings.title')}/i).click

    expect(page).to have_css('h2', text: I18n.t('dashboard.earnings_detail_view.title'))
    expect(page).to fit_the_phone_width

    find('turbo-frame#modal a', text: 'Maio').click

    expect(page).to have_css('h2', text: I18n.t('dashboard.earnings_detail_view.title_month'))
    expect(page).to have_text('Maio · 2026')
    expect(box(find("a[aria-label='#{I18n.t('dashboard.earnings_detail_view.edit')}']"))['height']).to be > 0
    expect(page).to fit_the_phone_width

    find("a[aria-label='#{I18n.t('dashboard.earnings_detail_view.back')}']").click

    expect(page).to have_css('h2', text: I18n.t('dashboard.earnings_detail_view.title'))
  end

  it 'gives the month row actions a 44px tap target on a phone' do
    visit root_path
    find('#stats_grid a', text: /\A#{I18n.t('dashboard.index_view.stats.expenses.title')}/i).click
    find('turbo-frame#modal a', text: 'Maio').click

    edit = find("a[aria-label='#{I18n.t('dashboard.expenses_detail_view.edit')}']")
    trash = find("button[aria-label='#{I18n.t('dashboard.expenses_detail_view.delete')}']")

    expect(page).to have_text('22 MAI')
    expect(box(edit)['height']).to be >= 44
    expect(box(trash)['height']).to be >= 44
    expect(page).to fit_the_phone_width
  end

  it 'lays the row actions as 32px-wide buttons 2px apart on a phone' do
    visit root_path
    find('#stats_grid a', text: /\A#{I18n.t('dashboard.index_view.stats.earnings.title')}/i).click
    find('turbo-frame#modal a', text: 'Maio').click

    edit = box(find("a[aria-label='#{I18n.t('dashboard.earnings_detail_view.edit')}']"))
    trash = box(find("button[aria-label='#{I18n.t('dashboard.earnings_detail_view.delete')}']"))

    expect(edit['width']).to eq(32)
    expect(trash['width']).to eq(32)
    expect(trash['x'] - edit['right']).to eq(2)
    expect(page).to fit_the_phone_width
  end

  it 'centers the modal card on a desktop screen' do
    emulate_desktop_screen

    visit root_path
    find('#stats_grid a', text: /\A#{I18n.t('dashboard.index_view.stats.earnings.title')}/i).click

    card = box(modal_card)

    expect(card['x'] + (card['width'] / 2)).to be_within(1).of(640)
    expect(card['width']).to eq(380)
  end
end
