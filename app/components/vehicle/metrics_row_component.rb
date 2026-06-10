class Vehicle
  class MetricsRowComponent < ApplicationComponent
    DESKTOP_TONES = {
      cost_per_km:    { bg: 'bg-red-50',     border: 'border-red-200',     value: 'text-red-900' },
      revenue_per_km: { bg: 'bg-emerald-50', border: 'border-emerald-200', value: 'text-emerald-900' },
      profit_per_km:  { bg: 'bg-blue-50',    border: 'border-blue-200',    value: 'text-blue-900' },
      km_per_liter:   { bg: 'bg-white',      border: 'border-slate-200',   value: 'text-slate-900' }
    }.freeze

    def initialize(metrics:, variant: :mobile)
      @metrics = metrics
      @variant = variant
    end

    def view_template
      @variant == :desktop ? desktop_template : mobile_template
    end

    private

    def mobile_template
      div(class: 'grid grid-cols-3 divide-x divide-slate-100 bg-white rounded-2xl border border-slate-200') do
        mobile_cell(:cost_per_km, format_currency(@metrics[:cost_per_km]))
        mobile_cell(:revenue_per_km, format_currency(@metrics[:revenue_per_km]))
        mobile_cell(:km_per_liter, consumption_value)
      end
    end

    def mobile_cell(key, value)
      div(class: 'p-3 text-center') do
        p(class: 'text-[10px] font-medium text-slate-500 uppercase tracking-wide') { t("vehicle.metrics.#{key}") }
        p(class: 'text-base font-bold text-slate-800 mt-1') { value }
      end
    end

    def desktop_template
      div(class: 'grid grid-cols-2 gap-4') do
        desktop_card(:cost_per_km, format_currency(@metrics[:cost_per_km]))
        desktop_card(:revenue_per_km, format_currency(@metrics[:revenue_per_km]))
        desktop_card(:profit_per_km, format_currency(@metrics[:profit_per_km]))
        desktop_card(:km_per_liter, consumption_value)
      end
    end

    def desktop_card(key, value)
      tone = DESKTOP_TONES[key]
      div(class: "rounded-2xl border p-5 #{tone[:bg]} #{tone[:border]}") do
        p(class: 'text-xs font-semibold uppercase tracking-wider text-slate-500') { t("vehicle.metrics.#{key}") }
        p(class: "text-2xl font-bold mt-2 #{tone[:value]} tabular-nums") { value }
      end
    end

    def consumption_value
      return t('vehicle.metrics.empty_value') if @metrics[:km_per_liter].nil?

      formatted = Kernel.format('%.1f', @metrics[:km_per_liter]).tr('.', ',')
      "#{formatted} km/L"
    end
  end
end
