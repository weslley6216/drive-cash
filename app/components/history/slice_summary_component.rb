module History
  class SliceSummaryComponent < ApplicationComponent
    def initialize(summary:)
      @summary = summary
    end

    def view_template
      div(class: 'grid grid-cols-3 gap-2 lg:gap-4', data: { slice_summary: 'tiles' }) do
        tile(label: first_label, value: format_currency(@summary[:total]), tone: tone_classes)
        tile(label: second_label, value: @summary[:count].to_s, tone: neutral_classes)
        tile(label: third_label, value: format_currency(third_value), tone: neutral_classes)
      end
    end

    private

    def tile(label:, value:, tone:)
      div(class: "rounded-xl border px-3 py-2 lg:px-5 lg:py-3 min-w-0 #{tone}") do
        p(class: 'text-[10px] font-medium uppercase tracking-wide opacity-70 lg:text-xs lg:font-semibold') { label }
        p(class: 'text-sm font-bold tabular-nums mt-0.5 lg:text-2xl lg:mt-1 truncate') { value }
      end
    end

    def first_label
      earnings? ? t('history.index.slice_summary.received') : t('history.index.slice_summary.spent')
    end

    def second_label
      fuel? ? t('history.index.slice_summary.refuelings') : t('history.index.slice_summary.records')
    end

    def third_label
      pending? ? t('history.index.slice_summary.pending') : t('history.index.slice_summary.average')
    end

    def third_value
      pending? ? @summary[:pending] : @summary[:average]
    end

    def tone_classes
      earnings? ? 'bg-emerald-50 border-emerald-200 text-emerald-900' : 'bg-red-50 border-red-200 text-red-900'
    end

    def neutral_classes
      'bg-white border-slate-200 text-slate-900'
    end

    def earnings?
      @summary[:kind] == :earnings
    end

    def fuel?
      @summary[:category] == 'fuel'
    end

    def pending?
      @summary[:pending].to_f.positive?
    end
  end
end
