module History
  class TableComponent < ApplicationComponent
    COLUMNS = %i[date type description status].freeze
    STATUS_TONES = {
      earning: 'text-emerald-700 bg-emerald-50 border-emerald-200',
      paid:    'text-emerald-700 bg-emerald-50 border-emerald-200',
      pending: 'text-amber-700 bg-amber-100 border-amber-200'
    }.freeze

    def initialize(groups:, context:)
      @groups = groups
      @context = context
    end

    def view_template
      div(class: 'bg-white rounded-xl border border-slate-200 overflow-hidden') do
        table(class: 'w-full text-sm') do
          head
          tbody do
            @groups.each do |group|
              group[:items].each { |record| row(group[:date], record) }
            end
          end
        end
      end
    end

    private

    def head
      thead(class: 'bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wide') do
        tr do
          COLUMNS.each { |column| th(class: 'text-left px-5 py-3') { t("history.index.table.#{column}") } }
          th(class: 'text-right px-5 py-3') { t('history.index.table.amount') }
          th(class: 'w-12')
        end
      end
    end

    def row(date, record)
      entry = EntryRows.for(record)
      tr(class: 'border-b border-slate-100 last:border-b-0 hover:bg-slate-50') do
        td(class: 'px-5 py-3 text-slate-500 whitespace-nowrap') { date_label(date) }
        td(class: 'px-5 py-3') do
          div(class: 'flex items-center gap-2') do
            render History::EntryIconComponent.new(row: entry, size: :table)
            span(class: 'text-slate-900 font-medium') { entry.label_text }
          end
        end
        td(class: 'px-5 py-3 text-slate-600') { entry.description_text }
        td(class: 'px-5 py-3') { status_pill(entry) }
        td(class: "px-5 py-3 text-right font-semibold tabular-nums whitespace-nowrap #{entry.amount_color}") do
          "#{entry.sign}#{format_currency(record.amount)}"
        end
        td(class: 'px-5 py-3 text-right') { edit_link(entry, record) }
      end
    end

    def status_pill(entry)
      span(class: "inline-flex items-center text-[10px] leading-5 font-bold uppercase tracking-wide border rounded-full px-2 py-0.5 #{STATUS_TONES.fetch(entry.status_key)}") do
        t("history.index.status.#{entry.status_key}")
      end
    end

    def edit_link(entry, record)
      link_to(public_send(entry.edit_route, record, context: @context),
              data:  { turbo_frame: 'modal' },
              aria:  { label: entry.edit_label },
              class: 'inline-flex text-slate-400 hover:text-slate-700') do
        render PhlexIcons::Lucide::Pencil.new(class: 'w-3.5 h-3.5')
      end
    end

    def date_label(date)
      return t('common.today') if date == Date.current
      return t('common.yesterday') if date == Date.current - 1

      I18n.l(date, format: '%-d/%b')
    end
  end
end
