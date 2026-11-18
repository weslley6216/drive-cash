module Records
  class EditView < ApplicationView
    include RecordFormData

    FORM_ID = 'record_edit_form'.freeze

    def initialize(earning: nil, expense: nil, context: {})
      @earning = earning
      @expense = expense
      context ||= {}
      @context = { year: context[:year], month: context[:month] }.compact
    end

    def view_template
      turbo_frame_tag 'modal' do
        div(class: 'fixed inset-0 z-50 flex flex-col bg-white safe-top lg:bg-black/30 lg:items-center lg:justify-center lg:p-8',
            data:  { controller: 'modal', action: 'mousedown->modal#handleBackgroundClick' }) do
          div(class: 'group/record h-full flex flex-col w-full min-h-0 lg:h-auto lg:max-h-full lg:max-w-2xl lg:bg-white lg:rounded-2xl ' \
                     'lg:shadow-2xl lg:border lg:border-slate-200 lg:overflow-hidden',
              data:  record_form_data(type: type, selected_category: @expense&.category.to_s, active_vendor: '')) do
            form_with(url: record_path, method: :patch, scope: :record, html: { id: FORM_ID, class: 'flex-1 min-h-0 flex flex-col' }) do
              input(type: 'hidden', name: 'context[year]', value: @context[:year])
              input(type: 'hidden', name: 'context[month]', value: @context[:month])

              top_bar
              desktop_header
              scrollable_body
            end
            render Records::StickyActionBarComponent.new(theme: cta_theme, form: FORM_ID) { cancel_button }
          end
        end
      end
    end

    private

    def earning? = @earning.present?

    def record = @earning || @expense

    def type = earning? ? 'earning' : 'expense'

    def record_path = earning? ? earning_path(@earning) : expense_path(@expense)

    def cta_theme = earning? ? :emerald : :red

    def top_bar
      div(class: 'px-5 pt-2 pb-3 flex items-center justify-between lg:hidden') do
        button(type: 'button', data: { action: 'modal#close' }, class: 'p-1 -ml-1 text-slate-500', aria: { label: t('records.new_view.close') }) do
          render PhlexIcons::Lucide::X.new(class: 'w-6 h-6')
        end
        p(class: 'text-sm font-semibold text-slate-700') { t('records.edit_view.title') }
        button(
          type:  'submit',
          class: 'text-sm font-semibold text-blue-600 cursor-pointer'
        ) { t('records.new_view.save') }
      end
    end

    def desktop_header
      div(class: 'hidden lg:flex items-center justify-between px-6 py-4 border-b border-slate-100') do
        h2(class: 'text-lg font-bold text-slate-900') { t('records.edit_view.title') }
        button(type: 'button', data: { action: 'modal#close' }, class: 'text-slate-400 hover:text-slate-700', aria: { label: t('records.new_view.close') }) do
          render PhlexIcons::Lucide::X.new(class: 'w-5 h-5')
        end
      end
    end

    def scrollable_body
      div(class: 'flex-1 min-h-0 overflow-y-auto px-5 pb-6 space-y-5 lg:px-6 lg:pt-5') do
        render Records::AmountAndDateComponent.new(amount: record.amount, date: record.date, theme: cta_theme)
        if earning?
          render Records::EarningFieldsComponent.new(earning: @earning)
        else
          render Records::ExpenseFieldsComponent.new(expense: @expense)
        end
        render Records::ErrorsComponent.new(record: record)
      end
    end

    def cancel_button
      button(type: 'button', data: { action: 'modal#close' }, class: 'hidden lg:inline px-4 py-2 text-sm font-medium text-slate-600 hover:text-slate-900') { t('records.new_view.cancel') }
    end
  end
end
