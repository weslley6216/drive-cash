module Vehicles
  class RefuelingsTableComponent < ApplicationComponent
    def initialize(entries:)
      @entries = entries
    end

    def view_template
      if @entries.empty?
        empty_state
      else
        table_layout
      end
    end

    private

    def empty_state
      div(class: 'bg-white rounded-xl border border-slate-200 p-6 text-center text-sm text-slate-500') do
        t('vehicle.refuelings.empty')
      end
    end

    def table_layout
      div(class: 'bg-white rounded-xl border border-slate-200 overflow-hidden') do
        table(class: 'w-full text-sm') do
          thead(class: 'bg-slate-50 text-xs uppercase text-slate-500') do
            tr do
              th(class: 'text-left px-4 py-3') { t('vehicle.refuelings.table_headers.date') }
              th(class: 'text-left px-4 py-3') { t('vehicle.refuelings.table_headers.vendor') }
              th(class: 'text-right px-4 py-3') { t('vehicle.refuelings.table_headers.price_per_liter') }
              th(class: 'text-right px-4 py-3') { t('vehicle.refuelings.table_headers.km_per_liter') }
              th(class: 'text-right px-4 py-3') { t('vehicle.refuelings.table_headers.total') }
            end
          end
          tbody do
            @entries.each { |entry| row_for(entry) }
          end
        end
      end
    end

    def row_for(entry)
      refueling = entry[:refueling]
      tr(class: 'border-t border-slate-100') do
        td(class: 'px-4 py-3 text-slate-700') { I18n.l(refueling.date, format: '%-d %b') }
        td(class: 'px-4 py-3 text-slate-800 font-medium') { refueling.vendor.presence || '—' }
        td(class: 'px-4 py-3 text-right text-slate-700 tabular-nums') { format_currency(refueling.price_per_liter) }
        td(class: 'px-4 py-3 text-right text-slate-700 tabular-nums') { km_per_liter_for(entry) }
        td(class: 'px-4 py-3 text-right font-semibold text-red-700 tabular-nums') { format_currency(refueling.total_amount) }
      end
    end

    def km_per_liter_for(entry)
      return '—' unless entry[:computed_km_per_liter]

      Kernel.format('%.1f', entry[:computed_km_per_liter]).tr('.', ',')
    end
  end
end
