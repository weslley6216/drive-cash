module Vehicles
  class RefuelingRowComponent < ApplicationComponent
    def initialize(refueling:, computed_km_per_liter:)
      @refueling = refueling
      @computed_km_per_liter = computed_km_per_liter
    end

    def view_template
      div(class: 'flex items-center gap-3 px-4 py-3') do
        div(class: 'w-10 h-10 rounded-lg bg-red-50 text-red-600 flex items-center justify-center flex-shrink-0') do
          render PhlexIcons::Lucide::Fuel.new(class: 'w-4 h-4')
        end
        div(class: 'flex-1 min-w-0') do
          p(class: 'text-sm font-semibold text-slate-800 truncate') { @refueling.vendor.presence || '—' }
          p(class: 'text-xs text-slate-500') { meta_line }
        end
        span(class: 'text-sm font-semibold text-red-700 whitespace-nowrap') { format_currency(@refueling.total_amount) }
      end
    end

    private

    def meta_line
      parts = []
      parts << I18n.l(@refueling.date, format: '%-d %b').downcase
      parts << t('vehicle.refuelings.liters', value: Kernel.format('%.1f', @refueling.liters).tr('.', ','))
      parts << t('vehicle.refuelings.km_per_l', value: Kernel.format('%.1f', @computed_km_per_liter).tr('.', ',')) if @computed_km_per_liter
      parts.join(' · ')
    end
  end
end
