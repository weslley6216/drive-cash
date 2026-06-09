module Dashboard
  module Insights
    class Presenter
      include Formatting

      I18N_SCOPE = 'analysis.show_view.insights'

      def initialize(raw)
        @raw = raw
      end

      def call
        {
          type:        @raw[:type],
          severity:    @raw[:severity],
          title:       title,
          description: description
        }
      end

      private

      def payload
        @raw[:payload]
      end

      def title
        case @raw[:type]
        when 'category_spike'
          I18n.t("#{I18N_SCOPE}.category_spike.title",
                 category: payload[:category],
                 pct: payload[:pct])
        when 'best_day'
          I18n.t("#{I18N_SCOPE}.best_day.title", value: format_currency(payload[:amount]))
        when 'worst_platform'
          I18n.t("#{I18N_SCOPE}.worst_platform.title", platform: payload[:platform])
        when 'margin_drop'
          I18n.t("#{I18N_SCOPE}.margin_drop.title", pp: payload[:pp])
        end
      end

      def description
        case @raw[:type]
        when 'category_spike'
          category_spike_description
        when 'best_day'
          I18n.t("#{I18N_SCOPE}.best_day.description",
                 date: I18n.l(payload[:date], format: :default))
        when 'worst_platform'
          I18n.t("#{I18N_SCOPE}.worst_platform.description",
                 platform: payload[:platform],
                 value: format_currency(payload[:per_trip]))
        when 'margin_drop'
          I18n.t("#{I18N_SCOPE}.margin_drop.description", value: payload[:current_margin])
        end
      end

      def category_spike_description
        if payload[:mode] == :monthly
          I18n.t("#{I18N_SCOPE}.category_spike.description_monthly",
                 category: payload[:category],
                 pct: payload[:pct],
                 value: format_currency(payload[:amount]),
                 period: I18n.t('date.month_names')[payload[:month]],
                 previous_year: payload[:previous_year])
        else
          I18n.t("#{I18N_SCOPE}.category_spike.description_annual",
                 category: payload[:category],
                 pct: payload[:pct],
                 value: format_currency(payload[:amount]),
                 previous_year: payload[:previous_year])
        end
      end
    end
  end
end
