module History
  class PeriodSummaryComponent < ApplicationComponent
    def initialize(summary:)
      @summary = summary
    end

    def view_template
      div(class: 'grid grid-cols-3 gap-3 mb-4') do
        render StatCardComponent.new(
          title: t('history.index.summary.earnings'),
          value: format_currency(@summary[:earnings]),
          color: :green,
          icon: PhlexIcons::Lucide::TrendingUp,
          value_size: 'text-sm lg:text-xl',
          padding: 'p-2 lg:p-4'
        )
        render StatCardComponent.new(
          title: t('history.index.summary.expenses'),
          value: format_currency(@summary[:expenses]),
          color: :red,
          icon: PhlexIcons::Lucide::TrendingDown,
          value_size: 'text-sm lg:text-xl',
          padding: 'p-2 lg:p-4'
        )
        render StatCardComponent.new(
          title: t('history.index.summary.net'),
          value: format_currency(@summary[:net]),
          color: :blue,
          icon: PhlexIcons::Lucide::Wallet,
          value_size: 'text-sm lg:text-xl',
          padding: 'p-2 lg:p-4'
        )
      end
    end
  end
end
