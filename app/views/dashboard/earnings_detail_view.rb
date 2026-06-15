module Dashboard
  class EarningsDetailView < DetailModalView
    def initialize(earnings:, total:, filters:, earnings_by_month: nil, annual: false)
      @earnings = earnings
      @earnings_by_month = earnings_by_month
      @total = total
      @annual = annual
      @filters = filters
      @theme = :blue
    end

    def view_template
      render_detail_modal(theme: @theme) do
        render_header(subtitle: period_subtitle(@filters))
        scrollable_content
        fixed_footer
      end
    end

    private

    def has_rows?
      @annual ? @earnings_by_month&.any? : @earnings.any?
    end

    def scrollable_content
      div(class: 'flex-1 overflow-y-auto p-6 pt-4') do
        if has_rows?
          earnings_table
        else
          p(class: 'text-slate-500 text-center py-8') { t('.empty') }
        end
      end
    end

    def earnings_table
      table(class: 'w-full text-left border-collapse') do
        thead do
          tr(class: 'border-b border-slate-200') do
            th(class: 'py-2 text-sm font-medium text-slate-600') do
              @annual ? t('.columns.month') : t('.columns.date')
            end
            th(class: 'py-2 text-sm font-medium text-slate-600 text-right w-1 whitespace-nowrap') do
              t('.columns.amount')
            end
          end
        end

        tbody do
          if @annual
            @earnings_by_month.each do |row|
              tr(class: 'border-b border-slate-100') do
                td(colspan: 2, class: 'p-0') do
                  link_to(
                    dashboard_earnings_detail_path(year: @filters[:year], month: row[:month]),
                    data:  { turbo_frame: 'modal' },
                    class: 'flex justify-between items-center w-full py-2.5 px-0 text-left text-slate-800 capitalize hover:bg-slate-50 transition-colors'
                  ) do
                    span { row[:month_name].to_s }
                    span(class: 'font-medium text-green-700') { format_currency(row[:total]) }
                  end
                end
              end
            end
          else
            @earnings.each do |earning|
              tr(class: 'border-b border-slate-100 group') do
                td(class: 'py-2.5 text-slate-800') { format_date(earning.date) }
                td(class: 'py-2.5 text-right w-1 whitespace-nowrap') do
                  div(class: 'flex items-center gap-2 flex-shrink-0 group justify-end') do
                    span(class: 'font-medium text-green-700') { format_currency(earning.amount) }
                    render_record_actions(
                      edit_path:   edit_earning_path(earning, context: { year: @filters[:year], month: @filters[:month] }),
                      delete_path: earning_path(earning, context: @filters),
                      edit_hover:  'hover:text-blue-600',
                      labels:      { edit: t('.edit'), delete: t('.delete'), confirm: t('.confirm_delete'), description: t('.confirm_delete_description') }
                    )
                  end
                end
              end
            end
          end
        end
      end
    end

    def fixed_footer
      render_detail_footer(
        annual:          @annual,
        show_total:      has_rows?,
        total:           @total,
        total_class:     'text-green-800',
        back_path:       dashboard_earnings_detail_path(year: @filters[:year]),
        labels:          {
          total: t('.total'),
          close: t('.close'),
          back:  t('.back')
        },
        padding_classes: 'px-6'
      )
    end
  end
end
