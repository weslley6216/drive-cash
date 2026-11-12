module Records
  class AmountInputComponent < ApplicationComponent
    THEME_TEXT = { red: 'text-red-700', emerald: 'text-emerald-700' }.freeze
    THEME_PLACEHOLDER = { red: 'placeholder:text-red-700', emerald: 'placeholder:text-emerald-700' }.freeze
    DESKTOP_BOX = 'lg:justify-start lg:gap-2 lg:rounded-xl lg:border-2 lg:p-4 lg:border-red-200 lg:bg-red-50 ' \
                  'lg:group-data-[type=earning]/record:border-emerald-200 lg:group-data-[type=earning]/record:bg-emerald-50'.freeze
    DESKTOP_VALUE = 'lg:text-4xl lg:w-full lg:text-left lg:tabular-nums lg:text-red-900 lg:group-data-[type=earning]/record:text-emerald-900'.freeze

    def initialize(amount:, theme:)
      @amount = amount&.to_s
      @theme = theme.to_sym
    end

    def view_template
      div(class: 'lg:col-span-2') do
        p(class: 'text-xs font-medium text-slate-500 uppercase tracking-wider mb-1 lg:font-semibold lg:text-slate-600 lg:tracking-wide lg:mb-1.5') do
          t('records.new_view.amount_label')
        end
        div(class: "flex items-baseline justify-center gap-1 #{DESKTOP_BOX} #{THEME_TEXT.fetch(@theme)}", data: { record_form_target: 'amountTheme' }) do
          span(class: 'text-2xl font-medium opacity-60 lg:text-xl') { 'R$' }
          input(
            type:         'text',
            inputmode:    'numeric',
            placeholder:  '0,00',
            autocomplete: 'off',
            class:        "text-6xl h-[60px] lg:h-10 font-bold tracking-tight bg-transparent text-center w-48 focus:outline-none placeholder:opacity-40 #{DESKTOP_VALUE} " \
                          "#{THEME_TEXT.fetch(@theme)} #{THEME_PLACEHOLDER.fetch(@theme)}",
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
