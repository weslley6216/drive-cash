module Chat
  module AnswerCards
    class SummaryComponent < ApplicationComponent
      STATS = 'rounded-xl bg-slate-50 border border-slate-200 px-3 divide-y divide-slate-200'.freeze

      def initialize(card:)
        @card = card
      end

      def view_template
        p { render_lead }
        div(class: STATS) { render_stats }
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
          label: t('chat.answer_card.summary.earnings'), value: "+#{format_currency(@card[:earnings])}",
          icon: PhlexIcons::Lucide::ArrowUpRight, tone: :emerald
        )
        render AnswerCards::AnswerStatComponent.new(
          label: t('chat.answer_card.summary.expenses'), value: "−#{format_currency(@card[:expenses])}",
          icon: PhlexIcons::Lucide::ArrowDownRight, tone: :red
        )
        render_best_day
      end

      def render_best_day
        return unless @card[:best_day_on]

        render AnswerCards::AnswerStatComponent.new(
          label: t('chat.answer_card.summary.best_day'), detail: best_day_detail,
          value: format_currency(@card[:best_day_amount]), icon: PhlexIcons::Lucide::Trophy, tone: :violet
        )
      end

      def best_day_detail
        date = Date.iso8601(@card[:best_day_on])
        t('chat.answer_card.summary.best_day_detail', weekday: I18n.l(date, format: '%a').capitalize, date: I18n.l(date, format: '%d/%m'))
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
