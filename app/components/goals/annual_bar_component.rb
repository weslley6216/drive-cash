module Goals
  class AnnualBarComponent < ApplicationComponent
    def initialize(progress:)
      @progress = progress
    end

    def view_template
      width = @progress[:percent].to_f.clamp(0, 100).round

      div(class: 'bg-white rounded-xl border border-slate-200 p-5') do
        div(class: 'flex items-center gap-3 mb-4') do
          div(class: 'w-8 h-8 rounded-full bg-purple-100 flex items-center justify-center text-purple-600') do
            render PhlexIcons::Lucide::Star.new(class: 'w-4 h-4')
          end
          div do
            p(class: 'text-sm font-semibold text-slate-800') { t('goals.index.annual.label') }
            p(class: 'text-xs text-slate-500') { year_label }
          end
        end
        p(class: 'text-2xl font-bold text-slate-900 tabular-nums') { brl(@progress[:current]) }
        p(class: 'text-xs text-slate-500 mt-0.5') do
          plain 'de '
          plain brl(@progress[:target])
        end
        div(class: 'h-2 bg-slate-100 rounded-full overflow-hidden mt-3') do
          div(class: 'h-full bg-gradient-to-r from-purple-400 to-purple-600 rounded-full', style: "width: #{width}%")
        end
        p(class: 'text-xs font-medium text-purple-700 mt-2') do
          plain "#{@progress[:percent].to_f.round(1)}% · "
          plain t('goals.index.annual.remaining_months', count: months_remaining)
        end
      end
    end

    private

    def year_label
      goal = @progress[:goal]
      goal&.period_start&.year&.to_s || Date.current.year.to_s
    end

    def months_remaining
      (@progress[:days_remaining].to_f / 30).round
    end

    def brl(value)
      helpers.number_to_currency(value, unit: 'R$', separator: ',', delimiter: '.')
    end
  end
end
