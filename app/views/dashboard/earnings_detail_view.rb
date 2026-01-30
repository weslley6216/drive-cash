module Dashboard
  class EarningsDetailView < ApplicationView
    def initialize(earnings:, total:, filters:, earnings_by_month: nil, annual: false)
      @earnings = earnings
      @earnings_by_month = earnings_by_month
      @total = total
      @annual = annual
      @filters = filters
      @theme = :blue
    end

    def view_template
      turbo_frame_tag 'modal' do
        div(
          class: modal_backdrop_classes,
          data_controller: 'modal',
          data_action: 'mousedown->modal#handleBackgroundClick'
        ) do
          div(
            class: "#{modal_content_classes} #{modal_theme_classes(theme: @theme)} max-w-lg flex flex-col max-h-[90vh]"
          ) do
            render_header(subtitle: period_subtitle)
            scrollable_content
            fixed_footer
          end
        end
      end
    end

    private

    def period_subtitle
      if @filters[:month].present?
        I18n.l(Date.new(@filters[:year], @filters[:month], 1), format: :month_and_year)
      else
        @filters[:year].to_s
      end
    end

    def scrollable_content
      div(class: 'flex-1 overflow-y-auto p-6 pt-4') do
        if @annual ? @earnings_by_month&.any? : @earnings.any?
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
            th(class: 'py-2 text-sm font-medium text-slate-600 text-right') do
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
                    data: { turbo_frame: 'modal' },
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
              tr(class: 'border-b border-slate-100') do
                td(class: 'py-2.5 text-slate-800') { format_date(earning.date) }
                td(class: 'py-2.5 text-right font-medium text-green-700') do
                  format_currency(earning.amount)
                end
              end
            end
          end
        end
      end
    end

    def fixed_footer
      div(class: 'border-t border-slate-200 bg-white') do
        if @annual ? @earnings_by_month&.any? : @earnings.any?
          div(
            class: 'flex justify-between items-center py-3 px-6 font-bold bg-slate-50 border-b border-slate-100'
          ) do
            span(class: 'text-slate-800') { t('.total') }
            span(class: 'text-green-800') { format_currency(@total) }
          end
        end

        div(class: 'px-6 py-3 flex justify-between items-center') do
          div(class: 'min-h-[2.5rem] flex items-center') do
            back_link unless @annual
          end

          button(
            type: 'button',
            data_action: 'modal#close',
            class: 'px-4 py-2 rounded-lg border border-slate-300 text-slate-700 hover:bg-slate-50 transition-colors',
            aria_label: t('.close')
          ) { t('.close') }
        end
      end
    end

    def back_link
      link_to(
        dashboard_earnings_detail_path(year: @filters[:year]),
        data: { turbo_frame: 'modal' },
        class: 'text-slate-400 hover:text-slate-600 transition-colors p-2 -ml-2 rounded-full hover:bg-slate-100',
        aria_label: t('.back'),
        title: t('.back')
      ) do
        render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-6 h-6')
      end
    end

    def format_date(date)
      I18n.l(date, format: :short)
    end
  end
end
