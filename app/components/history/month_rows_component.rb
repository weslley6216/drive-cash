module History
  class MonthRowsComponent < ApplicationComponent
    include CardStyles
    include SignedPercent

    def initialize(rows:, slice:, query:)
      @rows = rows
      @slice = slice
      @query = query
    end

    def view_template
      phone_list
      desktop_table
    end

    private

    def phone_list
      div(class: 'lg:hidden') do
        div(class: CARD) { @rows.each { |row| phone_row(row) } }
        p(class: 'text-[11px] text-slate-500 text-center mt-3') { t('history.index.twelve_months.tap_hint') }
      end
    end

    def phone_row(row)
      entry = entry_for(row)
      link_to(path_for(row), class: 'flex items-center gap-3 px-4 py-3 border-b border-slate-100 last:border-b-0', data: { month_row: 'phone' }) do
        render EntryIconComponent.new(row: entry)
        phone_body(row, entry)
        phone_amount(row, entry)
        render PhlexIcons::Lucide::ChevronRight.new(class: 'w-3.5 h-3.5 text-slate-300')
      end
    end

    def phone_body(row, entry)
      div(class: 'flex-1 min-w-0') do
        p(class: 'text-sm font-semibold text-slate-800') { month_title(row) }
        p(class: 'text-xs text-slate-500 truncate') { description(row, entry) }
      end
    end

    def phone_amount(row, entry)
      div(class: 'text-right') do
        p(class: "text-sm font-bold tabular-nums whitespace-nowrap #{entry.amount_color}", data: { month_amount: true }) { amount_text(row, entry) }
        phone_variation(row)
      end
    end

    def phone_variation(row)
      return if row[:change].nil?

      p(class: "text-[10px] font-semibold #{variation_color(row)}", data: { month_variation: true }) { variation_text(row) }
    end

    def desktop_variation(row)
      return if row[:change].nil?

      span(class: "text-xs font-semibold #{variation_color(row)}", data: { month_variation: true }) { variation_text(row) }
    end

    def variation_color(row) = row[:shift] ? 'text-amber-700' : 'text-slate-400'

    def desktop_table
      div(class: 'hidden lg:block') do
        div(class: 'bg-white rounded-xl border border-slate-200 overflow-hidden') do
          table(class: 'w-full text-sm') do
            desktop_head
            tbody { @rows.each { |row| desktop_row(row) } }
          end
        end
      end
    end

    def desktop_head
      thead(class: 'bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wide') do
        tr do
          th(class: 'text-left px-5 py-3') { t('history.index.month_table.month') }
          th(class: 'text-left px-5 py-3') { t('history.index.table.type') }
          th(class: 'text-left px-5 py-3') { t('history.index.table.description') }
          th(class: 'text-left px-5 py-3') { t('history.index.month_table.variation') }
          th(class: 'text-right px-5 py-3') { t('history.index.table.amount') }
          th(class: 'w-12')
        end
      end
    end

    def desktop_row(row)
      entry = entry_for(row)
      tr(class: 'relative cursor-pointer hover:bg-slate-50 border-b border-slate-100 last:border-b-0', data: { month_row: 'desktop' }) do
        td(class: 'px-5 py-3 text-slate-500 whitespace-nowrap') { month_short(row) }
        td(class: 'px-5 py-3') do
          div(class: 'flex items-center gap-2') do
            render EntryIconComponent.new(row: entry, size: :table)
            span(class: 'text-slate-900 font-medium') { entry.label_text }
          end
        end
        td(class: 'px-5 py-3 text-slate-600') { description(row, entry) }
        td(class: 'px-5 py-3') { desktop_variation(row) }
        td(class: "px-5 py-3 text-right font-semibold tabular-nums whitespace-nowrap #{entry.amount_color}") { amount_text(row, entry) }
        td(class: 'px-5 py-3 text-right') { desktop_chevron(row) }
      end
    end

    def desktop_chevron(row)
      link_to(path_for(row), class: 'after:absolute after:inset-0 inline-flex text-slate-400', aria: { label: month_title(row) }) do
        render PhlexIcons::Lucide::ChevronRight.new(class: 'w-3.5 h-3.5')
      end
    end

    def entry_for(row) = EntryRows.for(row[:record])

    def description(row, entry)
      row[:count] == 1 ? entry.description_text : t('history.index.twelve_months.entries', count: row[:count])
    end

    def amount_text(row, entry) = "#{entry.sign}#{format_currency(row[:total])}"

    def month_title(row) = "#{I18n.t('date.month_names')[row[:month]].capitalize} #{row[:year]}"

    def month_short(row) = "#{month_abbr(row[:month])}/#{'%02d' % (row[:year] % 100)}"

    def variation_text(row)
      return t('history.index.twelve_months.equal', month: short_month(row[:previous_month])) if row[:equal]

      t('history.index.twelve_months.versus', change: signed_percent(row[:change]), month: short_month(row[:previous_month]))
    end

    def path_for(row)
      history_path(year: row[:year], month: row[:month], **@slice.without_range.to_params, q: @query.presence)
    end
  end
end
