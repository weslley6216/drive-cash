module Goals
  class AnnualBarComponent < ApplicationComponent
    def initialize(progress:)
      @progress = progress
    end

    def view_template
      width = @progress[:percent].to_f.clamp(0, 100).round

      div(class: 'space-y-3') do
        div(class: 'flex items-baseline justify-between') do
          span(class: 'text-sm font-medium text-slate-600') { t('goals.index.annual.label') }
          span(class: 'text-xs text-slate-500') do
            plain t('goals.index.annual.remaining_months', count: months_remaining)
          end
        end
        div(class: 'w-full h-3 bg-slate-100 rounded-full overflow-hidden') do
          div(class: 'h-full bg-violet-500 rounded-full', style: "width: #{width}%")
        end
        div(class: 'flex items-baseline justify-between text-sm text-slate-600') do
          span { brl(@progress[:current]) }
          span(class: 'text-slate-400') { brl(@progress[:target]) }
        end
      end
    end

    private

    def months_remaining
      (@progress[:days_remaining].to_f / 30).round
    end

    def brl(value)
      helpers.number_to_currency(value, unit: 'R$', separator: ',', delimiter: '.')
    end
  end
end
