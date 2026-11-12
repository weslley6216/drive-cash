module Records
  class TripsStepperComponent < ApplicationComponent
    STEP_BUTTON = 'w-7 h-7 lg:w-8 lg:h-8 rounded-full bg-slate-100 lg:bg-white lg:border lg:border-slate-300 text-slate-700 ' \
                  'flex items-center justify-center text-base font-bold cursor-pointer'.freeze

    def initialize(value: 1)
      @value = value.to_i
    end

    def view_template
      div(class: Records::NewView::DETAIL_CARD) do
        p(class: Records::NewView::DETAIL_LABEL) do
          span(class: 'lg:hidden') { t('records.new_view.trips_count') }
          span(class: 'hidden lg:inline') { t('records.new_view.trips_count_long') }
        end
        div(class: 'flex items-center justify-between lg:mt-1') do
          button(
            type:  'button',
            class: STEP_BUTTON,
            data:  { action: 'click->record-form#decrementTrips' }
          ) { '−' }
          span(class: 'text-xl font-bold text-slate-800 lg:text-2xl lg:text-slate-900 lg:tabular-nums', data: { record_form_target: 'tripsValue' }) { @value.to_s }
          button(
            type:  'button',
            class: STEP_BUTTON,
            data:  { action: 'click->record-form#incrementTrips' }
          ) { '+' }
        end
        input(
          type:  'hidden',
          name:  'record[trips_count]',
          value: @value,
          data:  { record_form_target: 'tripsInput' }
        )
      end
    end
  end
end
