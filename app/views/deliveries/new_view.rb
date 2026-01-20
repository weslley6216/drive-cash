# frozen_string_literal: true

module Deliveries
  class NewView < ApplicationComponent
    include Phlex::Rails::Helpers::TurboFrameTag
    include Phlex::Rails::Helpers::FormWith
    include FormFields
    include ModalStyles
    include ButtonStyles

    def initialize(delivery:)
      @delivery = delivery
    end

    def view_template
      turbo_frame_tag 'modal' do
        modal_backdrop
      end
    end

    private

    def modal_backdrop
      div(
        class: modal_backdrop_classes,
        data_controller: 'modal',
        data_action: 'mousedown->modal#handleBackgroundClick'
      ) do
        modal_content
      end
    end

    def modal_content
      div(class: modal_content_classes) do
        modal_header
        modal_form
      end
    end

    def modal_header
      div(class: modal_header_classes) do
        h2(class: modal_title_classes) { t('.title') }
        close_button
      end
    end

    def close_button
      button(
        type: 'button',
        data_action: 'modal#close',
        class: modal_close_button_classes
      ) do
        render IconComponent.new(name: :x, class: 'w-6 h-6')
      end
    end

    def modal_form
      form_with(model: @delivery, class: 'p-6 space-y-4', data: { controller: 'calculator' }) do |f|
        render_form_fields(f)
      end
    end

    def render_form_fields(f)
      date_field(f)
      money_field(f, :route_value, label: t('.labels.route_value'), required: true, calculator: 'earning')
      money_field(f, :fuel_cost, label: t('.labels.fuel_cost'), calculator: 'cost')
      money_field(f, :maintenance_cost, label: t('.labels.maintenance_cost'), calculator: 'cost')
      money_field(f, :other_costs, label: t('.labels.other_costs'), calculator: 'cost')
      profit_preview
      form_actions
    end

    def date_field(f)
      field_wrapper(t('.labels.date')) do
        render f.date_field(:date, value: Date.current, class: input_classes)
      end
    end

    def profit_preview
      div(class: 'bg-blue-50 border-2 border-blue-200 rounded-lg p-4 my-4') do
        p(class: 'text-sm text-slate-600 mb-1') { t('.profit_preview') }
        p(
          class: 'text-2xl font-bold text-blue-700',
          data: { calculator_target: 'result' }
        ) { 'R$ 0,00' }
      end
    end

    def form_actions
      div(class: 'flex gap-3 pt-4') do
        cancel_button
        submit_button
      end
    end

    def cancel_button
      button(
        type: 'button',
        data_action: 'modal#close',
        class: button_classes(variant: :secondary, full_width: true)
      ) { t('.buttons.cancel') }
    end

    def submit_button
      button(
        type: 'submit',
        class: "#{button_classes(variant: :primary, full_width: true)} flex items-center justify-center gap-2 shadow-md active:scale-95"
      ) do
        render IconComponent.new(name: :save, class: 'w-5 h-5 text-white opacity-100')
        span { t('.buttons.save') }
      end
    end
  end
end
