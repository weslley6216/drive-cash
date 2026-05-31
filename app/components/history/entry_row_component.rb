module History
  class EntryRowComponent < ApplicationComponent
    EARNING_STYLE = {
      icon: PhlexIcons::Lucide::Truck,
      icon_bg: 'bg-emerald-50',
      icon_color: 'text-emerald-600',
      amount_color: 'text-emerald-700',
      sign: '+'
    }.freeze

    EXPENSE_STYLE = {
      icon: PhlexIcons::Lucide::Receipt,
      icon_bg: 'bg-red-50',
      icon_color: 'text-red-600',
      amount_color: 'text-red-700',
      sign: '−'
    }.freeze

    def initialize(record:, context:)
      @record  = record
      @context = context
    end

    def view_template
      link_to(
        edit_path,
        data: { turbo_frame: 'modal' },
        class: 'flex items-center gap-3 px-4 py-3 hover:bg-slate-50 transition-colors',
        aria_label: edit_label,
        title: edit_label
      ) do
        icon_block
        body_block
        amount_block
      end
    end

    private

    def style
      earning? ? EARNING_STYLE : EXPENSE_STYLE
    end

    def earning?
      @record.is_a?(Earning)
    end

    def edit_path
      if earning?
        edit_earning_path(@record, context: @context)
      else
        edit_expense_path(@record, context: @context)
      end
    end

    def edit_label
      t(earning? ? 'history.index.edit.earning' : 'history.index.edit.expense')
    end

    def label_text
      if earning?
        I18n.t("activerecord.attributes.earning.platforms.#{@record.platform}")
      else
        I18n.t("activerecord.attributes.expense.categories.#{@record.category}")
      end
    end

    def description_text
      if earning?
        @record.notes.presence || I18n.t('common.trips', count: @record.trips_count)
      else
        @record.vendor.presence || @record.description.to_s
      end
    end

    def icon_block
      div(class: class_names('flex items-center justify-center w-10 h-10 rounded-lg shrink-0', style[:icon_bg], style[:icon_color])) do
        render style[:icon].new(class: 'w-4 h-4')
      end
    end

    def body_block
      div(class: 'flex-1 min-w-0') do
        div(class: 'flex items-center gap-2 min-w-0') do
          p(class: 'text-sm font-medium text-slate-900 truncate') { label_text }
          pending_badge if unpaid_expense?
        end
        p(class: 'text-xs text-slate-500 truncate') { description_text }
      end
    end

    def amount_block
      span(class: class_names('text-sm font-semibold shrink-0', style[:amount_color])) do
        "#{style[:sign]} #{format_currency(@record.amount)}"
      end
    end

    def unpaid_expense?
      !earning? && @record.paid == false
    end

    def pending_badge
      span(class: pending_badge_classes) { t('history.index.day_group.unpaid_badge') }
    end

    def pending_badge_classes
      'text-[9px] font-bold uppercase tracking-wide text-amber-700 bg-amber-100 ' \
        'border border-amber-200 rounded-full px-1.5 py-0.5 shrink-0'
    end
  end
end
