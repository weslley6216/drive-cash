module Chat
  module AnswerCards
    class VendorEfficiencyComponent < ApplicationComponent
      WINNER_COLOR = '#10b981'
      RUNNER_UP_COLOR = '#94a3b8'

      def initialize(card:)
        @card = card
      end

      def view_template
        p { render_lead }
        div(class: 'space-y-2') { render_bars }
        render_savings
      end

      private

      def render_lead
        plain "#{t('chat.answer_card.vendor_efficiency.lead_before')} "
        strong { @card[:winner] }
        plain " #{lead_after}"
      end

      def lead_after
        t('chat.answer_card.vendor_efficiency.lead_after',
          winner_kml:    kml_value(@card[:winner_kml]),
          runner_up_kml: kml_value(@card[:runner_up_kml]),
          runner_up:     @card[:runner_up])
      end

      def render_bars
        render_bar(name: @card[:winner], kml: @card[:winner_kml], width: 100, color: WINNER_COLOR)
        render_bar(name: @card[:runner_up], kml: @card[:runner_up_kml], width: runner_up_width, color: RUNNER_UP_COLOR)
      end

      def runner_up_width = (@card[:runner_up_kml] / @card[:winner_kml] * 100).round

      def render_bar(name:, kml:, width:, color:)
        div do
          div(class: 'flex items-center justify-between text-xs mb-1') do
            span(class: 'text-slate-600 font-medium') { name }
            span(class: 'text-slate-500 tabular-nums') { t('chat.answer_card.vendor_efficiency.kml', value: kml_value(kml)) }
          end
          div(class: 'h-1.5 bg-slate-100 rounded-full overflow-hidden') do
            div(class: 'h-full rounded-full', style: "width: #{width}%; background: #{color}")
          end
        end
      end

      def kml_value(value) = number_with_precision(value, precision: 1, separator: ',')

      def render_savings
        return unless @card[:savings].positive?

        p(class: 'text-xs text-slate-500') do
          plain "#{t('chat.answer_card.vendor_efficiency.savings_label')} "
          strong(class: 'text-slate-700') { savings_value }
          plain " #{savings_hint}"
        end
      end

      def savings_value
        t('chat.answer_card.vendor_efficiency.savings_value', value: format_currency_short(@card[:savings]))
      end

      def savings_hint
        t('chat.answer_card.vendor_efficiency.savings_hint', vendor: @card[:winner])
      end
    end
  end
end
