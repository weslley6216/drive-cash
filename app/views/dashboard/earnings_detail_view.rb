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
          div(class: "#{modal_content_classes} #{modal_theme_classes(theme: @theme)} max-w-lg") do
            render_header(subtitle: period_subtitle)
            list_section
            close_action
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

    def list_section
      div(class: 'p-6 pt-4') do
        if @annual ? @earnings_by_month&.any? : @earnings.any?
          table(class: 'w-full text-left border-collapse') do
            thead do
              tr(class: 'border-b border-slate-200') do
                th(class: 'py-2 text-sm font-medium text-slate-600') { @annual ? t('.columns.month') : t('.columns.date') }
                th(class: 'py-2 text-sm font-medium text-slate-600 text-right') { t('.columns.amount') }
              end
            end
            tbody do
              if @annual
                @earnings_by_month.each do |row|
                  tr(class: 'border-b border-slate-100') do
                    td(class: 'py-2.5 text-slate-800 capitalize') { row[:month_name].to_s }
                    td(class: 'py-2.5 text-right font-medium text-green-700') { format_currency(row[:total]) }
                  end
                end
              else
                @earnings.each do |earning|
                  tr(class: 'border-b border-slate-100') do
                    td(class: 'py-2.5 text-slate-800') { format_date(earning.date) }
                    td(class: 'py-2.5 text-right font-medium text-green-700') { format_currency(earning.amount) }
                  end
                end
              end
            end
            tfoot do
              tr(class: 'border-t-2 border-slate-300 bg-slate-50 font-bold') do
                td(class: 'py-3 text-slate-800') { t('.total') }
                td(class: 'py-3 text-right text-green-800') { format_currency(@total) }
              end
            end
          end
        else
          p(class: 'text-slate-500 text-center py-8') { t('.empty') }
        end
      end
    end

    def format_date(date)
      I18n.l(date, format: :short)
    end

    def close_action
      div(class: 'p-6 pt-0 flex justify-end') do
        button(
          type: 'button',
          data_action: 'modal#close',
          class: 'px-4 py-2 rounded-lg border border-slate-300 text-slate-700 hover:bg-slate-50 transition-colors',
          aria_label: t('.close')
        ) { t('.close') }
      end
    end
  end
end
