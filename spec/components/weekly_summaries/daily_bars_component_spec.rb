require 'rails_helper'

RSpec.describe WeeklySummaries::DailyBarsComponent, type: :component do
  let(:week) { Calendars::Week.containing(Date.new(2026, 7, 6)) }
  let(:today) { Date.new(2026, 7, 20) }
  let(:profits) { [182, 240, 0, 156, 268, 141, 0] }
  let(:best_day_index) { 4 }
  let(:empty_days) { [] }
  let(:blank_week) { false }
  let(:days) do
    week.range.zip(profits).map do |date, profit|
      WeeklySummaries::Builder::Day.new(date: date, profit: profit, earnings: profit.zero? ? 0 : profit + 100,
                                        expenses: profit.zero? ? 0 : 100, trips: profit.zero? ? 0 : 5,
                                        empty: profit.zero?, future: date > today)
    end
  end
  let(:html) do
    view_context.render(described_class.new(week: week, days: days, best_day_index: best_day_index,
                                            empty_days: empty_days, blank_week: blank_week))
  end
  let(:page_html) { Capybara.string(html) }

  it 'labels the bars from monday to sunday' do
    labels = html.scan(/<span class="text-\[10px\][^"]*">([^<]+)<\/span>/).flatten

    expect(labels).to eq(%w[seg ter qua qui sex sáb dom])
  end

  it 'highlights the best day and scales bars as a share of the track' do
    expect(html).to include('bg-blue-600')
    expect(html).to include('height: 100.0%')
    expect(html).to include('bg-blue-200')
    expect(html).to include('height: 89.6%')
    expect(html).to include('bg-slate-100')
    expect(html).to include('height: 4px')
  end

  it 'grows the track from 96px on the phone to 150px on the desktop' do
    expect(html).to include('h-[96px] lg:h-[150px]')
  end

  it 'wires the shared bar tooltip with the side placement, the outside dismissal and the 0.4 dimming' do
    chart = page_html.find('[data-controller="bar-tooltip"]')

    expect(chart['class']).to include('relative')
    expect(chart['data-bar-tooltip-placement-value']).to eq('above-or-side')
    expect(chart['data-bar-tooltip-dismiss-outside-value']).to eq('true')
    expect(chart['data-bar-tooltip-dim-opacity-value']).to eq('0.4')
    expect(chart['data-bar-tooltip-negative-class']).to eq('text-red-400')
    expect(chart['data-bar-tooltip-positive-class']).to eq('text-white')
  end

  it 'renders the dark tooltip with the date label, the bold net, the three rows and the hidden no-data line' do
    tooltip = page_html.find('[data-bar-tooltip-target="tooltip"]', visible: :all)

    expect(tooltip['class']).to include('absolute', 'z-20', 'pointer-events-none', 'hidden')
    expect(tooltip).to have_css('.relative.bg-slate-900.text-white.rounded-lg.px-3.py-2.shadow-xl.whitespace-nowrap', visible: :all)
    expect(tooltip).to have_css('p.uppercase.tracking-wide[data-bar-tooltip-target="label"]', visible: :all)
    expect(tooltip).to have_css('p.hidden[data-bar-tooltip-target="noData"]', text: 'Sem lançamentos', visible: :all)
    expect(tooltip).to have_css('[data-bar-tooltip-target="values"][class~="min-w-[126px]"]', visible: :all)
    expect(tooltip).to have_css('p.text-base.font-bold.tabular-nums[data-bar-tooltip-target="field"][data-field="net"][data-signed="true"]', visible: :all)
    expect(tooltip).to have_css('p', text: 'líquido do dia', visible: :all)
    expect(tooltip).to have_css('[data-field="earnings"]', visible: :all)
    expect(tooltip).to have_css('[data-field="expenses"]', visible: :all)
    expect(tooltip).to have_css('[data-field="trips"]', visible: :all)
    expect(tooltip).to have_css('span.bg-emerald-400', visible: :all)
    expect(tooltip).to have_css('span.bg-red-400', visible: :all)
    expect(tooltip).to have_css('svg.text-slate-400', visible: :all)
    expect(tooltip.text(:all)).to include('Receitas', 'Despesas', 'Corridas')
    expect(tooltip).to have_css('.bg-slate-900[data-bar-tooltip-target="arrow"]', visible: :all)
  end

  it 'exposes the formatted day values on each bar for the tooltip' do
    monday = page_html.find('[data-weekday="0"]')

    expect(monday['data-bar-tooltip-target']).to eq('column')
    expect(monday['data-index']).to eq('0')
    expect(monday['data-label-text']).to eq('seg, 06/jul')
    expect(monday['data-muted']).to eq('false')
    expect(monday['data-negative']).to eq('false')
    expect(monday['data-net']).to eq('R$ 182,00')
    expect(monday['data-earnings']).to eq('R$ 282,00')
    expect(monday['data-expenses']).to eq('R$ 100,00')
    expect(monday['data-trips']).to eq('5')
    expect(monday).to have_css('[data-bar-tooltip-target="fill"]')
  end

  it 'makes each past bar a button announcing the day and its values' do
    monday = page_html.find('[data-weekday="0"]')

    expect(monday['role']).to eq('button')
    expect(monday['tabindex']).to eq('0')
    expect(monday['class']).to include('rounded-md', 'outline-none', 'cursor-pointer')
    expect(monday['data-action']).to eq(BarTooltip::COLUMN_ACTIONS)
    expect(monday['aria-label']).to eq('Seg, 06/jul: líquido R$ 182,00, receitas R$ 282,00, despesas R$ 100,00, 5 corridas')
  end

  it 'marks a day without records as muted and announces it' do
    wednesday = page_html.find('[data-weekday="2"]')

    expect(wednesday['data-muted']).to eq('true')
    expect(wednesday['aria-label']).to eq('Qua, 08/jul: Sem lançamentos')
  end

  context 'with the days after today in the current week' do
    let(:today) { Date.new(2026, 7, 8) }
    let(:profits) { [182, 240, 0, 0, 0, 0, 0] }
    let(:best_day_index) { 1 }

    it 'leaves the future bars inert with a lighter label' do
      thursday = page_html.find('[data-weekday="3"]', visible: :all)

      expect(thursday['aria-hidden']).to eq('true')
      expect(thursday['role']).to be_nil
      expect(thursday['tabindex']).to be_nil
      expect(thursday['data-action']).to be_nil
      expect(thursday['class']).not_to include('cursor-pointer')
      expect(thursday).to have_css('span.text-slate-300', text: 'qui')
      expect(page_html).to have_css('[data-bar-tooltip-target="column"]', count: 3)
    end
  end

  context 'with days without records' do
    let(:empty_days) { [Date.new(2026, 7, 8), Date.new(2026, 7, 12)] }

    it 'announces the best day and the days without records' do
      expect(html).to include('Sexta foi o melhor dia:')
      expect(html).to include('R$ 268,00')
      expect(html).to include('Quarta e domingo sem lançamentos.')
    end
  end

  context 'with a loss on monday' do
    let(:profits) { [-50, 0, 0, 0, 0, 0, 0] }
    let(:best_day_index) { nil }

    it 'stubs a day with negative profit' do
      expect(html).to include('bg-slate-100')
      expect(html).to include('height: 4px')
    end

    it 'flags only the negative net to tint the tooltip red' do
      expect(page_html).to have_css('[data-weekday="0"][data-negative="true"]')
      expect(page_html).to have_css('[data-weekday="0"][data-net="-R$ 50,00"]')
      expect(page_html).to have_css('[data-weekday="1"][data-negative="false"]')
    end
  end

  context 'on a week without profit' do
    let(:profits) { [0, 0, 0, 0, 0, 0, 0] }
    let(:best_day_index) { nil }

    it 'omits the best day sentence when no day is profitable' do
      expect(html).not_to include('melhor dia')
    end

    context 'with three days without records' do
      let(:empty_days) { [Date.new(2026, 7, 7), Date.new(2026, 7, 9), Date.new(2026, 7, 11)] }

      it 'joins three days without records in a sentence' do
        expect(html).to include('Terça, quinta e sábado sem lançamentos.')
      end
    end

    context 'when the whole week is blank' do
      let(:empty_days) { week.range.to_a }
      let(:blank_week) { true }

      it 'says the week has no records instead of the day sentences on a blank week' do
        expect(html).to include('Nenhum lançamento nesta semana.')
        expect(html).not_to include('sem lançamentos')
      end
    end
  end
end
