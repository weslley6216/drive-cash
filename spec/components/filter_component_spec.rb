require 'rails_helper'

RSpec.describe FilterComponent, type: :component do
  let(:available_years) { [2026, 2025, 2024] }

  before { travel_to Time.zone.local(2026, 5, 22, 10, 0) }

  def render_filter(**options)
    view_context.render(described_class.new(selected_year: 2026, selected_month: nil, available_years: available_years, **options))
  end

  context 'when variant: :compact' do
    let(:html) { render_filter(selected_month: 2, action_path: '/history') }

    it 'renders the year and month selects as prototype filter pills' do
      expect(html).to include('rounded-lg py-2 text-sm font-medium text-slate-700')
      expect(html.scan('m6 9 6 6 6-6').size).to eq(2)
      expect(html).to include('absolute left-3 w-3.5 h-3.5 text-slate-500')
    end

    it 'labels the months with full names and the empty option as every month' do
      expect(html).to include('value="2" selected>Fevereiro</option>')
      expect(html).to include(">#{I18n.t('filter_component.all_months')}</option>")
    end

    it 'offers only the elapsed months of the current year in the month select' do
      expect(html).to include('value="5">Maio</option>')
      expect(html).not_to include('value="6">Junho</option>')
    end

    it 'offers every month of a past year in the month select' do
      past = render_filter(selected_year: 2025)

      expect(past).to include('value="12">Dezembro</option>')
    end

    it 'selects the chosen year' do
      expect(html).to include('value="2026" selected')
      expect(html).not_to include('value="2025" selected')
    end

    it 'submits the form through the filter controller on the given path' do
      expect(html).to include('action="/history"')
      expect(html).to include('data-controller="filter"')
      expect(html).to include('change->filter#handleYearChange')
    end
  end

  context 'when variant: :chips' do
    let(:html) { render_filter(variant: :chips, selected_month: 3) }

    it 'renders a funnel year pill and one chip per elapsed month on phones' do
      expect(html).to include('absolute left-3 w-3.5 h-3.5 text-slate-700')
      expect(html).to include(">#{I18n.t('filter_component.all_chip')}</span></a>")
      expect(html).to include('href="/?month=5&year=2026"')
      expect(html).not_to include('month=6')
    end

    it 'marks only the active chip as the strip target' do
      expect(html).to include('data-controller="chip-strip"')
      expect(html.scan('data-chip-strip-target="active"').size).to eq(1)
      expect(html).to include('href="/?month=3&year=2026" class="flex-shrink-0 flex items-center h-11" data-chip-strip-target="active"><span class="px-3 py-1.5 rounded-full text-sm whitespace-nowrap bg-slate-800 text-white font-medium">Mar</span>')
    end

    it 'leaves the desktop pills to the compact variant' do
      expect(html).not_to include('hidden lg:block')
    end

    it 'lists every month for a past year' do
      past = render_filter(variant: :chips, selected_year: 2025)

      expect(past).to include('href="/?month=12&year=2025"')
    end
  end

  context 'when variant: :popover' do
    let(:periods) { { 2025 => [3, 11], 2026 => [1, 2, 5] } }
    let(:html) { render_filter(variant: :popover, selected_month: 2, periods: periods, action_path: '/analysis') }

    it 'renders a funnel button that toggles a hidden panel kept open across year switches' do
      expect(html).to include('data-controller="filter-popover"')
      expect(html).to include('data-filter-popover-persistent-value="true"')
      expect(html).to include('click@window->filter-popover#closeOnOutsideClick')
      expect(html).to match(/class="hidden absolute right-0 top-full/)
    end

    it 'lists only the months of the selected year from the calendar as links' do
      expect(html).to include(">#{I18n.t('filter_component.all_months')}</a>")
      expect(html).to include('href="/analysis?month=5&year=2026"')
      expect(html).to include('bg-blue-600 text-white font-semibold">Fev</a>')
      expect(html).not_to include('month=3&year=2026')
    end

    it 'heads the panel with the year between arrows instead of a year select' do
      expect(html).to include('text-[11px] font-semibold text-slate-500 uppercase tracking-wide tabular-nums">2026</p>')
      expect(html).to include('href="/analysis?year=2025"')
      expect(html).to include(%(aria-label="#{I18n.t('filter_component.previous_year')}"))
      expect(html).to include('data-action="filter-popover#keepOpen"')
      expect(html).not_to include('name="year"')
    end

    it 'hides the arrow past the last year of the calendar but keeps its space' do
      expect(html).to include('w-7 h-7 rounded-lg flex items-center justify-center text-slate-500 hover:bg-slate-100 invisible')
      expect(html).not_to include(%(aria-label="#{I18n.t('filter_component.next_year')}"))
    end

    it 'points the next arrow at the following year of the calendar with every month selected' do
      first_year = render_filter(variant: :popover, selected_year: 2025, periods: periods, action_path: '/analysis')

      expect(first_year).to include('href="/analysis?year=2026"')
      expect(first_year).to include(%(aria-label="#{I18n.t('filter_component.next_year')}"))
      expect(first_year).to include('href="/analysis?month=11&year=2025"')
    end

    it 'opens the same panel from a calendar pill labelled with the month and the year on desktops' do
      expect(html).to include('hidden lg:flex items-center gap-2 px-3.5 py-2 rounded-lg border border-slate-200 bg-white ' \
                              'text-sm font-medium text-slate-700 hover:bg-slate-50')
      expect(html).to include('Fevereiro 2026')
      expect(html.scan('click->filter-popover#toggle').size).to eq(2)
      expect(html).not_to include('change->filter#handleYearChange')
    end

    it 'labels the desktop pill with the whole year and highlights every month when no month is selected' do
      annual = render_filter(variant: :popover, periods: periods, action_path: '/analysis')

      expect(annual).to include(I18n.t('filter_component.year_all_months', year: 2026))
      expect(annual).to include("bg-blue-50 text-blue-700 font-semibold\">#{I18n.t('filter_component.all_months')}</a>")
    end
  end
end
