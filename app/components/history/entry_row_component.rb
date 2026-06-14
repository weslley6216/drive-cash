module History
  class EntryRowComponent < ApplicationComponent
    def initialize(record:, context:)
      @record  = record
      @context = context
      @row     = EntryRows.for(record)
    end

    def view_template
      link_to(
        public_send(@row.edit_route, @record, context: @context),
        data: { turbo_frame: 'modal' },
        class: 'flex items-center gap-3 px-4 py-3 hover:bg-slate-50 transition-colors',
        aria_label: @row.edit_label,
        title: @row.edit_label
      ) do
        icon_block
        body_block
        amount_block
      end
    end

    private

    def icon_block
      div(class: class_names('flex items-center justify-center w-10 h-10 rounded-lg shrink-0', @row.icon_bg, @row.icon_color)) do
        render @row.icon.new(class: 'w-4 h-4')
      end
    end

    def body_block
      div(class: 'flex-1 min-w-0') do
        div(class: 'flex items-center gap-2 min-w-0') do
          p(class: 'text-sm font-medium text-slate-900 truncate') { @row.label_text }
          pending_badge if @row.unpaid?
        end
        p(class: 'text-xs text-slate-500 truncate') { @row.description_text }
      end
    end

    def amount_block
      span(class: class_names('text-sm font-semibold shrink-0', @row.amount_color)) do
        "#{@row.sign} #{format_currency(@record.amount)}"
      end
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
