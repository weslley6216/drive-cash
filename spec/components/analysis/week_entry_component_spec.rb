require 'rails_helper'

RSpec.describe Analysis::WeekEntryComponent, type: :component do
  before { travel_to Time.zone.local(2026, 7, 14, 10, 0) }

  let(:week) { Calendars::Week.containing(Date.current) }
  let(:html) do
    Capybara.string(view_context.render(described_class.new(week: week, href: '/weekly_summaries/2026-07-13?return_to=%2Fanalysis')))
  end

  it 'links the whole card to the given week outside the analysis frame and hides it on the desktop' do
    link = html.find("a[href='/weekly_summaries/2026-07-13?return_to=%2Fanalysis']")

    expect(link['data-turbo-frame']).to eq('_top')
    expect(link[:class]).to include('lg:hidden')
    expect(link[:class]).to include('bg-white rounded-xl shadow-sm border border-slate-100 px-4 py-3')
  end

  it 'names the current week with its range under the title' do
    expect(html).to have_css('p.text-sm.font-semibold.text-slate-800', exact_text: 'Sua semana')
    expect(html).to have_css('p.text-xs.text-slate-500.truncate', exact_text: 'Esta semana · 13 a 19 de julho')
  end

  it 'shows the chart icon in a blue bubble and the chevron without any value' do
    expect(html).to have_css('div.w-9.h-9.rounded-lg.bg-blue-50.text-blue-600 svg')
    expect(html).to have_css('svg.text-slate-400')
    expect(html).to have_no_text('R$')
  end

  context 'when the week crosses two months' do
    let(:week) { Calendars::Week.containing(Date.new(2026, 7, 1)) }

    it 'spells both months in the range' do
      expect(html).to have_css('p.truncate', exact_text: 'Esta semana · 29 de junho a 5 de julho')
    end
  end
end
