module Records
  class NewView < ApplicationView
    include CardStyles

    DETAIL_CARD = "#{CardStyles::CARD} p-3 lg:bg-slate-50 lg:border-slate-200 lg:shadow-none".freeze
    DETAIL_LABEL = 'text-[10px] font-medium text-slate-500 uppercase tracking-wide mb-1 block lg:font-semibold lg:mb-0'.freeze
    INSTALLMENT_INPUT = 'w-full px-4 py-2 rounded-lg border focus:outline-none focus:ring-2 transition-all border-slate-300 ' \
                        'text-slate-900 focus:ring-red-500 focus:border-red-500 bg-white'.freeze

    def initialize(type:, earning: nil, expense: nil, context: nil, active_vendor: nil)
      @type = type.to_s
      @earning = earning || Earning.new(date: Date.current)
      @expense = expense || Expense.new(date: Date.current)
      @context = context || {}
      @active_vendor = active_vendor.to_s
    end

    def view_template
      render LayoutComponent.new(title: t('records.new_view.title'), app_shell: true) do
        div(class: 'h-full flex flex-col bg-white max-w-[640px] mx-auto w-full lg:max-w-none lg:bg-black/30 lg:items-center lg:justify-center lg:p-8') do
          div(class: 'group/record h-full flex flex-col w-full min-h-0 lg:h-auto lg:max-h-full lg:max-w-2xl lg:bg-white lg:rounded-2xl ' \
                     'lg:shadow-2xl lg:border lg:border-slate-200 lg:overflow-hidden',
              data:  stimulus_data) do
            form_with(url: records_path, method: :post, scope: :record, html: { class: 'h-full flex flex-col min-h-0' }) do
              input(type: 'hidden', name: 'context[year]', value: @context[:year])
              input(type: 'hidden', name: 'context[month]', value: @context[:month])

              top_bar
              desktop_header
              type_toggle_section
              scrollable_body
              render Records::StickyActionBarComponent.new(theme: cta_theme)
            end
          end
        end
      end
    end

    private

    def earning? = @type == 'earning'
    def expense? = @type == 'expense'

    def stimulus_data
      { controller:                          'record-form',
        type:                                @type,
        record_form_type_value:              @type,
        record_form_active_vendor_value:     @active_vendor,
        record_form_selected_category_value: @expense.category.to_s,
        record_form_months_value:            I18n.t('date.abbr_month_names').compact.to_json,
        record_form_day_names_value:         I18n.t('date.day_names').to_json,
        record_form_today_value:             Date.current.iso8601,
        record_form_today_label_value:       t('records.new_view.today'),
        record_form_yesterday_label_value:   t('common.yesterday') }
    end

    def cta_theme
      earning? ? :emerald : :red
    end

    def top_bar
      div(class: 'px-5 pt-2 pb-3 flex items-center justify-between lg:hidden') do
        link_to(root_path, class: 'p-1 -ml-1 text-slate-500', aria: { label: t('records.new_view.close') }) do
          render PhlexIcons::Lucide::X.new(class: 'w-6 h-6')
        end
        p(class: 'text-sm font-semibold text-slate-700') { t('records.new_view.title') }
        button(
          type:  'submit',
          class: 'text-sm font-semibold text-blue-600 cursor-pointer'
        ) { t('records.new_view.save') }
      end
    end

    def desktop_header
      div(class: 'hidden lg:flex items-center justify-between px-6 py-4 border-b border-slate-100') do
        h2(class: 'text-lg font-bold text-slate-900') { t('records.new_view.title') }
        link_to(root_path, class: 'text-slate-400 hover:text-slate-700', aria: { label: t('records.new_view.close') }) do
          render PhlexIcons::Lucide::X.new(class: 'w-5 h-5')
        end
      end
    end

    def type_toggle_section
      div(class: 'px-5 pb-3 lg:px-6 lg:pt-6 lg:pb-0') do
        render Records::EntryTypeToggleComponent.new(active: @type)
      end
    end

    def scrollable_body
      div(class: 'flex-1 min-h-0 overflow-y-auto px-5 pb-6 space-y-5 lg:px-6 lg:pt-5') do
        amount_and_date_section
        earning_block
        expense_block
        flash_errors
      end
    end

    def amount_and_date_section
      div(class: 'py-4 text-center lg:py-0 lg:text-left lg:grid lg:grid-cols-3 lg:gap-4') do
        render Records::AmountInputComponent.new(amount: shared_amount, theme: cta_theme)
        date_cell
      end
    end

    def date_cell
      label(class: 'relative mt-2 inline-flex cursor-pointer lg:mt-0 lg:flex lg:flex-col') do
        span(class: 'hidden lg:block text-xs font-semibold uppercase tracking-wide text-slate-600 mb-1.5') { t('records.new_view.date_label') }
        span(class: 'inline-flex items-center gap-1 text-xs text-slate-400 lg:flex lg:flex-col lg:items-start lg:justify-center lg:gap-0 ' \
                    'lg:w-full lg:h-[78px] lg:rounded-xl lg:border lg:border-slate-200 lg:bg-white lg:px-3 lg:text-sm') do
          render PhlexIcons::Lucide::Calendar.new(class: 'w-3 h-3 lg:hidden')
          span(class: 'lg:text-[11px] lg:leading-5', data: { record_form_target: 'dateRelative' }) { relative_date_label }
          span(class: 'lg:hidden') { '·' }
          span(class: 'lg:text-slate-900 lg:font-medium', data: { record_form_target: 'dateText' }) { I18n.l(shared_date, format: '%-d %b %Y') }
        end
        input(
          type:  'date',
          name:  'record[date]',
          value: shared_date.to_s,
          aria:  { label: t('records.new_view.date_label') },
          class: 'absolute inset-0 w-full h-full opacity-0 cursor-pointer',
          data:  { action: 'change->record-form#refreshDate click->record-form#openDatePicker' }
        )
      end
    end

    def relative_date_label
      return t('records.new_view.today') if shared_date == Date.current
      return t('common.yesterday') if shared_date == Date.current - 1

      I18n.t('date.day_names')[shared_date.wday].capitalize
    end

    def shared_amount
      (earning? ? @earning.amount : @expense.amount)
    end

    def shared_date
      (earning? ? @earning.date : @expense.date) || Date.current
    end

    def earning_block
      div(class: (earning? ? '' : 'hidden'), data: { record_form_target: 'earningFields' }) do
        render Records::PlatformPickerComponent.new(selected: @earning.platform)
        details_section do
          render Records::TripsStepperComponent.new(value: @earning.trips_count || 1)
          notes_card
        end
      end
    end

    def expense_block
      div(class: (expense? ? '' : 'hidden'),
          data:  { record_form_target: 'expenseFields' }) do
        render Records::CategoryPickerComponent.new(selected: @expense.category)
        details_section do
          vendor_card
          description_card
        end
        div(class: 'mt-3 space-y-3') do
          paid_toggle
          installment_section
        end
      end
    end

    def details_section(&)
      div(class: 'mt-5 space-y-3') do
        p(class: 'text-xs font-bold text-slate-500 uppercase tracking-wider lg:hidden') { t('records.new_view.details') }
        div(class: 'space-y-3 lg:space-y-0 lg:grid lg:grid-cols-2 lg:gap-3', &)
      end
    end

    def notes_card
      div(class: DETAIL_CARD) do
        label(class: DETAIL_LABEL) { t('records.new_view.notes_label') }
        textarea(name: 'record[notes]', rows: 2, class: 'w-full text-sm text-slate-800 bg-transparent focus:outline-none resize-none', placeholder: t('records.new_view.notes_placeholder')) { @earning.notes }
      end
    end

    def vendor_card
      div(class: DETAIL_CARD) do
        label(class: DETAIL_LABEL) { t('records.new_view.vendor_label') }
        input(type: 'text', name: 'record[vendor]', value: @expense.vendor,
              placeholder: t('records.new_view.vendor_placeholder'),
              class: 'w-full text-sm text-slate-800 bg-transparent focus:outline-none lg:mt-1 lg:font-medium lg:text-slate-900',
              data: { record_form_target: 'vendorInput',
                      action:             'input->record-form#refreshVendorUi' })
        vendor_inheritance_hint
      end
    end

    def vendor_inheritance_hint
      div(class: 'mt-2 hidden', data: { record_form_target: 'vendorHint' }) do
        div(class: 'flex items-center gap-2 text-xs text-slate-500') do
          span(class: 'inline-flex items-center gap-1.5 text-amber-600 font-medium') do
            span(class: 'w-1.5 h-1.5 rounded-full bg-amber-400')
            span { t('records.new_view.vendor_inherited') }
          end
          button(type: 'button', class: 'cursor-pointer text-slate-400 underline underline-offset-2 hover:text-slate-600',
                 data: { action: 'click->record-form#clearVendor' }) { t('records.new_view.vendor_clear') }
        end
      end
      div(class: 'mt-2 hidden', data: { record_form_target: 'vendorSuggest' }) do
        button(type:  'button',
               class: 'cursor-pointer inline-flex items-center gap-1.5 rounded-full border border-slate-200 bg-white px-3 py-1.5 text-xs font-medium text-slate-600 hover:border-slate-300 shadow-sm',
               data:  { action: 'click->record-form#applyVendor' }) do
          render PhlexIcons::Lucide::Fuel.new(class: 'w-3 h-3 text-amber-500')
          span(data: { record_form_target: 'vendorSuggestLabel' })
          span(class: 'text-slate-400') { "· #{t('records.new_view.vendor_from_tank')}" }
        end
      end
    end

    def description_card
      div(class: DETAIL_CARD) do
        label(class: DETAIL_LABEL) { t('records.new_view.description_label') }
        textarea(name: 'record[description]', rows: 2, class: 'w-full text-sm text-slate-800 bg-transparent focus:outline-none resize-none', placeholder: t('records.new_view.description_placeholder')) { @expense.description }
      end
    end

    def paid_toggle
      checked = @expense.new_record? ? true : !!@expense.paid
      div(class: 'bg-emerald-50 border border-emerald-200 rounded-xl px-4 py-3 flex items-center justify-between') do
        div do
          p(class: 'text-sm font-semibold text-emerald-900') { t('records.new_view.paid_toggle.title') }
          p(class: 'text-xs text-emerald-700') { t('records.new_view.paid_toggle.subtitle') }
        end
        label(class: 'relative inline-flex cursor-pointer items-center') do
          input(type: 'hidden', name: 'record[paid]', value: '0')
          input(type: 'checkbox', name: 'record[paid]', value: '1', checked: checked, class: 'peer sr-only')
          span(class: 'h-6 w-11 rounded-full bg-slate-300 transition-colors peer-checked:bg-emerald-500')
          span(class: 'pointer-events-none absolute left-0.5 top-0.5 h-5 w-5 rounded-full bg-white shadow transition-transform peer-checked:translate-x-5')
        end
      end
    end

    def installment_section
      div(
        class: 'rounded-xl border border-slate-200 bg-slate-50 px-4 py-3',
        data:  { controller: 'expense-installment', action: 'change->expense-installment#toggle' }
      ) do
        label(for: 'installment_repeat', class: 'flex items-center justify-between gap-3 cursor-pointer') do
          div do
            p(class: 'text-sm font-semibold text-slate-800') { t('records.new_view.recurring_toggle.title') }
            p(class: 'text-xs text-slate-500') { t('records.new_view.recurring_toggle.subtitle') }
          end
          span(class: 'relative inline-flex flex-shrink-0 items-center') do
            raw helpers.check_box_tag('installment[repeat]', '1', false, id: 'installment_repeat', class: 'peer sr-only')
            span(class: 'h-6 w-11 rounded-full bg-slate-300 transition-colors peer-checked:bg-red-500')
            span(class: 'pointer-events-none absolute left-0.5 top-0.5 h-5 w-5 rounded-full bg-white shadow transition-transform peer-checked:translate-x-5')
          end
        end
        div(class: 'hidden mt-3 pt-3 space-y-3 border-t border-slate-200', data: { expense_installment_target: 'fields' }) do
          div do
            label(for: 'installment_period', class: 'block text-sm font-medium mb-2 text-slate-700') { t('records.new_view.installment.period_label') }
            raw helpers.select_tag('installment[period]', helpers.options_for_select(installment_periods, 'monthly'), class: INSTALLMENT_INPUT)
          end
          div do
            label(for: 'installment_repetitions', class: 'block text-sm font-medium mb-2 text-slate-700') { t('records.new_view.installment.repetitions_label') }
            raw helpers.number_field_tag('installment[repetitions]', 3, min: 2, step: 1, class: INSTALLMENT_INPUT)
          end
          p(class: 'text-xs text-slate-500') { t('records.new_view.installment.repeat_hint') }
        end
      end
    end

    def installment_periods
      Expense::INSTALLMENT_PERIODS.map { |period| [t("records.new_view.installment.periods.#{period}"), period] }
    end

    def flash_errors
      record = earning? ? @earning : @expense
      return unless record.errors.any?

      div(class: 'rounded-xl border border-red-300 bg-red-50 text-red-700 text-sm px-4 py-3') do
        plain record.errors.full_messages.to_sentence
      end
    end
  end
end
