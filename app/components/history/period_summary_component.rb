module History
  class PeriodSummaryComponent < ApplicationComponent
    TONES = {
      earnings: { box: 'bg-emerald-50 border-emerald-200', label: 'text-emerald-700', value: 'text-emerald-900' },
      expenses: { box: 'bg-red-50 border-red-200', label: 'text-red-700', value: 'text-red-900' },
      net:      { box: 'bg-blue-50 border-blue-200', label: 'text-blue-700', value: 'text-blue-900' }
    }.freeze

    def initialize(summary:)
      @summary = summary
    end

    def view_template
      div(class: 'grid grid-cols-3 gap-2 lg:gap-4') do
        TONES.each { |key, tone| tile(key, tone) }
      end
    end

    private

    def tile(key, tone)
      div(class: "#{tone[:box]} border rounded-xl px-3 py-2 lg:px-5 lg:py-3 min-w-0") do
        p(class: "text-[10px] font-medium uppercase tracking-wide lg:text-xs lg:font-semibold #{tone[:label]}") do
          t("history.index.summary.#{key}")
        end
        p(class: "text-sm font-bold #{tone[:value]} mt-0.5 lg:text-2xl lg:tabular-nums lg:mt-1 truncate") do
          format_currency(@summary[key])
        end
      end
    end
  end
end
