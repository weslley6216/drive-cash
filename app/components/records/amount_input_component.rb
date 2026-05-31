module Records
  class AmountInputComponent < ApplicationComponent
    THEME_TEXT = { red: 'text-red-700', emerald: 'text-emerald-700' }.freeze

    def initialize(amount:, theme:, date:)
      @amount = amount&.to_s
      @theme = theme.to_sym
      @date = date || Date.current
    end

    def view_template
      div(class: 'py-4') do
        div(class: 'text-center') do
          p(class: 'text-xs font-medium text-slate-500 uppercase tracking-wider mb-1') do
            t('records.new_view.amount_label')
          end
          div(class: "flex items-baseline justify-center gap-1 #{THEME_TEXT.fetch(@theme)}", data: { record_form_target: 'amountTheme' }) do
            span(class: 'text-2xl font-medium opacity-60') { 'R$' }
            input(
              type: 'number',
              step: '0.01',
              min: '0',
              name: 'record[amount]',
              value: @amount,
              placeholder: '0,00',
              class: 'text-6xl font-bold tracking-tight bg-transparent text-center w-48 focus:outline-none',
              data: { record_form_target: 'amount' }
            )
          end
        end
        div(class: 'mt-3') do
          label(class: 'text-xs font-medium text-slate-500 uppercase tracking-wider block mb-1 text-center') do
            render PhlexIcons::Lucide::Calendar.new(class: 'w-3 h-3 inline-block mr-1')
            plain t('records.new_view.today')
          end
          input(
            type: 'date',
            name: 'record[date]',
            value: @date.to_s,
            class: 'w-full text-sm text-slate-700 bg-transparent border border-slate-200 rounded-lg px-3 py-2 focus:outline-none focus:border-slate-400'
          )
        end
      end
    end
  end
end
