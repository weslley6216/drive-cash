module History
  class SliceYearComponent < ApplicationComponent
    include CardStyles
    include SignedPercent

    NO_BREAK_SPACE = "\u00A0".freeze

    def initialize(year:, slice:, query:)
      @year = year
      @slice = slice
      @query = query
    end

    def view_template
      div(class: "#{CARD} p-4 lg:px-6 lg:py-4 lg:flex lg:gap-8 lg:items-end", data: { twelve_months: 'card' }) do
        left_block
        bars
      end
    end

    private

    def left_block
      div(class: 'lg:flex-shrink-0') do
        header
        totals_row
      end
    end

    def header
      div(class: 'flex items-center justify-between mb-1') do
        p(class: 'text-[10px] font-bold uppercase tracking-wider text-slate-500') { title }
        div(class: 'lg:hidden') { render ModeToggleComponent.new(slice: @slice, query: @query) }
      end
    end

    def totals_row
      div(class: 'flex items-end justify-between gap-2 mb-2 lg:mb-0 lg:block', data: { twelve_months: 'totals' }) do
        div do
          p(class: "text-xl font-bold tabular-nums lg:text-3xl lg:mt-1 #{total_color}", data: { twelve_months: 'total' }) { format_currency(@year[:total]) }
          p(class: 'text-[11px] text-slate-500 lg:text-xs', data: { twelve_months: 'summary' }) { summary_text }
        end
        adjustment_badge if shift
      end
    end

    def adjustment_badge
      span(class: badge_classes, data: { twelve_months: 'adjustment' }) do
        plain t('history.index.twelve_months.adjustment', change: signed_percent(shift[:change]), month: short_month(shift[:month]))
        plain ' '
        span(class: 'hidden lg:inline') do
          t('history.index.twelve_months.adjustment_levels', from: format_currency(shift[:from]), to: format_currency(shift[:to]))
        end
      end
    end

    def badge_classes
      'text-[10px] font-bold text-amber-800 bg-amber-100 border border-amber-200 rounded-full px-2 py-1 whitespace-nowrap ' \
        'lg:inline-block lg:mt-3 lg:text-[11px] lg:px-2.5'
    end

    def bars
      div(class: 'lg:flex-1') do
        render MonthBarsComponent.new(months: @year[:months], earnings: earnings?, highlighted: @year[:highlighted], size: :year)
      end
    end

    def title
      t('history.index.twelve_months.title', label: label)
    end

    def summary_text
      t('history.index.twelve_months.summary', average: format_currency(@year[:average]).sub(' ', NO_BREAK_SPACE))
    end

    def label
      earnings? ? t("activerecord.attributes.earning.platforms.#{@year[:series]}") : t("activerecord.attributes.expense.categories.#{@year[:series]}")
    end

    def total_color
      earnings? ? 'text-emerald-700' : 'text-red-700'
    end

    def earnings?
      @year[:kind] == :earnings
    end

    def shift
      @year[:shift]
    end
  end
end
