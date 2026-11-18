module Records
  class EarningFieldsComponent < ApplicationComponent
    def initialize(earning:)
      @earning = earning
    end

    def view_template
      render Records::PlatformPickerComponent.new(selected: @earning.platform)
      render Records::DetailsSectionComponent.new do
        render Records::TripsStepperComponent.new(value: @earning.trips_count || 1)
        notes_card
      end
    end

    private

    def notes_card
      div(class: Records::DetailsSectionComponent::CARD) do
        label(class: Records::DetailsSectionComponent::LABEL) { t('records.new_view.notes_label') }
        textarea(name: 'record[notes]', rows: 2, class: 'w-full text-sm text-slate-800 bg-transparent focus:outline-none resize-none', placeholder: t('records.new_view.notes_placeholder')) { @earning.notes }
      end
    end
  end
end
