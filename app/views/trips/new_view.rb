module Trips
  class NewView < ApplicationView
    def initialize(trip:, context: {})
      @trip = trip
      @context = context || {}
      @theme = :blue
    end

    def view_template
      turbo_frame_tag 'modal' do
        div(class: modal_backdrop_classes, data_controller: 'modal', data_action: 'mousedown->modal#handleBackgroundClick') do
          div(class: "#{modal_content_classes} #{modal_theme_classes(theme: @theme)}") do
            render_header  # <- SEM subtitle, mais simples
            render_form
          end
        end
      end
    end

    private

    def render_form
      form_with(model: @trip, url: trips_path, class: 'p-6 space-y-4', data: { controller: 'calculator' }) do |f|
        hidden_context_fields

        date_field(f, :date, label: t('.labels.date'), theme: @theme)
        money_fields(f)
        render_profit_preview
        render_actions
      end
    end

    def hidden_context_fields
      input(type: 'hidden', name: 'context[year]', value: @context[:year] || Date.current.year)
      input(type: 'hidden', name: 'context[month]', value: @context[:month])
    end

    def money_fields(form)
      money_field(form, :route_value, label: t('.labels.route_value'), theme: @theme, required: true, calculator: 'earning')
      money_field(form, :fuel_cost, label: t('.labels.fuel_cost'), theme: @theme, calculator: 'cost')
      money_field(form, :maintenance_cost, label: t('.labels.maintenance_cost'), theme: @theme, calculator: 'cost')
      money_field(form, :other_costs, label: t('.labels.other_costs'), theme: @theme, calculator: 'cost')
    end

    def render_profit_preview
      div(class: 'bg-blue-50 border-2 border-blue-200 rounded-lg p-4 my-4') do
        p(class: 'text-sm text-slate-600 mb-1') { t('.profit_preview') }
        p(class: 'text-2xl font-bold text-blue-700', data: { calculator_target: 'result' }) { 'R$ 0,00' }
      end
    end

    def render_actions
      div(class: 'flex gap-3 pt-4') do
        button(type: 'button', data_action: 'modal#close', class: button_classes(variant: :secondary, full_width: true)) { t('.buttons.cancel') }
        button(type: 'submit', class: "#{button_classes(variant: :primary, full_width: true)} flex items-center justify-center gap-2") do
          render PhlexIcons::Lucide::Save.new(class: 'w-5 h-5')
          span { t('.buttons.save') }
        end
      end
    end
  end
end
