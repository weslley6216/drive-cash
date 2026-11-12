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

    it 'highlights the selected month chip' do
      expect(html).to include('href="/?month=3&year=2026" class="flex-shrink-0 flex items-center h-11"><span class="px-3 py-1.5 rounded-full text-sm whitespace-nowrap bg-slate-800 text-white font-medium">Mar</span>')
    end

    it 'keeps the pills for desktop screens' do
      expect(html).to include('hidden lg:block')
      expect(html).to include('absolute left-3 w-3.5 h-3.5 text-slate-500')
    end

    it 'lists every month for a past year' do
      past = render_filter(variant: :chips, selected_year: 2025)

      expect(past).to include('href="/?month=12&year=2025"')
    end
  end

  context 'when variant: :popover' do
    let(:html) { render_filter(variant: :popover, selected_month: 2, action_path: '/analysis') }

    it 'renders a funnel button that toggles a hidden panel' do
      expect(html).to include('data-controller="filter-popover"')
      expect(html).to include('click@window->filter-popover#closeOnOutsideClick')
      expect(html).to include('click->filter-popover#toggle')
      expect(html).to match(/class="hidden absolute right-0 top-full/)
    end

    it 'offers every month and the elapsed months as links in the panel' do
      expect(html).to include(">#{I18n.t('filter_component.all_months')}</a>")
      expect(html).to include('href="/analysis?month=2&year=2026"')
      expect(html).to include('bg-blue-600 text-white font-semibold">Fev</a>')
    end

    it 'keeps a year select in the panel caption' do
      expect(html).to include(%(aria-label="#{I18n.t('filter_component.year')}"))
      expect(html).to include('name="year"')
    end

    it 'puts a calendar icon on both desktop pills' do
      expect(html.scan('absolute left-3 w-3.5 h-3.5 text-slate-500').size).to eq(2)
    end

    it 'highlights every month when no month is selected' do
      annual = render_filter(variant: :popover, action_path: '/analysis')

      expect(annual).to include("bg-blue-50 text-blue-700 font-semibold\">#{I18n.t('filter_component.all_months')}</a>")
    end
  end
end
