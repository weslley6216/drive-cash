module Records
  class TripsStepperComponent < ApplicationComponent
    def initialize(value: 1)
      @value = value.to_i
    end

    def view_template
      div(class: 'rounded-xl border border-slate-200 bg-white p-3') do
        p(class: 'text-[10px] font-medium text-slate-500 uppercase tracking-wide mb-1') do
          t('records.new_view.trips_count')
        end
        div(class: 'flex items-center justify-between') do
          button(
            type: 'button',
            class: 'w-7 h-7 rounded-full bg-slate-100 text-slate-700 flex items-center justify-center text-base font-bold cursor-pointer',
            data: { action: 'click->record-form#decrementTrips' }
          ) { '−' }
          span(class: 'text-xl font-bold text-slate-800', data: { record_form_target: 'tripsValue' }) { @value.to_s }
          button(
            type: 'button',
            class: 'w-7 h-7 rounded-full bg-slate-100 text-slate-700 flex items-center justify-center text-base font-bold cursor-pointer',
            data: { action: 'click->record-form#incrementTrips' }
          ) { '+' }
        end
        input(
          type: 'hidden',
          name: 'record[trips_count]',
          value: @value,
          data: { record_form_target: 'tripsInput' }
        )
      end
    end
  end
end
