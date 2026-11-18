module Records
  class AmountAndDateComponent < ApplicationComponent
    def initialize(amount:, date:, theme:)
      @amount = amount
      @date = date || Date.current
      @theme = theme.to_sym
    end

    def view_template
      div(class: 'py-4 text-center lg:py-0 lg:text-left lg:grid lg:grid-cols-3 lg:gap-4') do
        render Records::AmountInputComponent.new(amount: @amount, theme: @theme)
        date_cell
      end
    end

    private

    def date_cell
      label(class: 'relative mt-2 inline-flex cursor-pointer lg:mt-0 lg:flex lg:flex-col') do
        span(class: 'hidden lg:block text-xs font-semibold uppercase tracking-wide text-slate-600 mb-1.5') { t('records.new_view.date_label') }
        span(class: 'inline-flex items-center gap-1 text-xs text-slate-400 lg:flex lg:flex-col lg:items-start lg:justify-center lg:gap-0 ' \
                    'lg:w-full lg:h-[78px] lg:rounded-xl lg:border lg:border-slate-200 lg:bg-white lg:px-3 lg:text-sm') do
          render PhlexIcons::Lucide::Calendar.new(class: 'w-3 h-3 lg:hidden')
          span(class: 'lg:text-[11px] lg:leading-5', data: { record_form_target: 'dateRelative' }) { relative_date_label }
          span(class: 'lg:hidden') { '·' }
          span(class: 'lg:text-slate-900 lg:font-medium', data: { record_form_target: 'dateText' }) { I18n.l(@date, format: '%-d %b %Y') }
        end
        input(
          type:  'date',
          name:  'record[date]',
          value: @date.to_s,
          aria:  { label: t('records.new_view.date_label') },
          class: 'absolute inset-0 w-full h-full opacity-0 cursor-pointer',
          data:  { action: 'change->record-form#refreshDate click->record-form#openDatePicker' }
        )
      end
    end

    def relative_date_label
      return t('records.new_view.today') if @date == Date.current
      return t('common.yesterday') if @date == Date.current - 1

      I18n.t('date.day_names')[@date.wday].capitalize
    end
  end
end
