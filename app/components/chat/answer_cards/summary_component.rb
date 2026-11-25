module Chat
  module AnswerCards
    class SummaryComponent < ApplicationComponent
      def initialize(card:)
        @card = card
      end

      def view_template
        p { render_lead }
        div(class: 'rounded-xl bg-slate-50 border border-slate-200 p-3 flex gap-3') { render_stats }
      end

      private

      def render_lead
        plain "#{lead} "
        strong { format_currency(@card[:profit]) }
        plain " #{change}" if @card[:profit_change]
        plain '.'
      end

      def render_stats
        render AnswerCards::AnswerStatComponent.new(
          label: t('chat.answer_card.summary.earnings'), value: "+#{format_currency(@card[:earnings])}", tone: :emerald
        )
        div(class: 'w-px bg-slate-200')
        render AnswerCards::AnswerStatComponent.new(
          label: t('chat.answer_card.summary.expenses'), value: "−#{format_currency(@card[:expenses])}", tone: :red
        )
        render_best_day
      end

      def render_best_day
        return unless @card[:best_day_on]

        div(class: 'w-px bg-slate-200')
        render AnswerCards::AnswerStatComponent.new(
          label: t('chat.answer_card.summary.best_day'), value: best_day_value, tone: :slate
        )
      end

      def best_day_value
        day = I18n.l(Date.iso8601(@card[:best_day_on]), format: '%a').capitalize
        t('chat.answer_card.summary.best_day_value', day: day, value: format_currency_short(@card[:best_day_amount]))
      end

      def lead
        t('chat.answer_card.summary.lead', period: period_label)
      end

      def change
        key = @card[:profit_change] >= 0 ? :change_up : :change_down
        t("chat.answer_card.summary.#{key}", pct: number_to_percentage(@card[:profit_change].abs, precision: 0))
      end

      def period_label
        return current_month? ? t('chat.answer_card.summary.period.current_month') : month_label if @card[:month]

        current_year? ? t('chat.answer_card.summary.period.current_year') : t('chat.answer_card.summary.period.year', year: @card[:year])
      end

      def month_label
        t('chat.answer_card.summary.period.month', month: I18n.t('date.month_names')[@card[:month]])
      end

      def current_month? = @card[:year] == Date.current.year && @card[:month] == Date.current.month
      def current_year? = @card[:year] == Date.current.year
    end
  end
end
