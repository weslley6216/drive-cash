module Records
  class AmountInputComponent < ApplicationComponent
    THEME_TEXT        = { red: 'text-red-700',             emerald: 'text-emerald-700' }.freeze
    THEME_PLACEHOLDER = { red: 'placeholder:text-red-700', emerald: 'placeholder:text-emerald-700' }.freeze

    def initialize(amount:, theme:)
      @amount = amount&.to_s
      @theme = theme.to_sym
    end

    def view_template
      div(class: 'py-4 text-center') do
        p(class: 'text-xs font-medium text-slate-500 uppercase tracking-wider mb-1') do
          t('records.new_view.amount_label')
        end
        div(class: "flex items-baseline justify-center gap-1 #{THEME_TEXT.fetch(@theme)}", data: { record_form_target: 'amountTheme' }) do
          span(class: 'text-2xl font-medium opacity-60') { 'R$' }
          input(
            type:         'text',
            inputmode:    'numeric',
            placeholder:  '0,00',
            autocomplete: 'off',
            class:        "text-6xl font-bold tracking-tight bg-transparent text-center w-48 focus:outline-none placeholder:opacity-40 #{THEME_TEXT.fetch(@theme)} #{THEME_PLACEHOLDER.fetch(@theme)}",
            data:         { record_form_target: 'amountDisplay', action: 'input->record-form#formatAmount' }
          )
          input(
            type:  'hidden',
            name:  'record[amount]',
            value: @amount,
            data:  { record_form_target: 'amountInput' }
          )
        end
      end
    end
  end
end
