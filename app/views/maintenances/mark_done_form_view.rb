module Maintenances
  class MarkDoneFormView < ApplicationView
    include MaintenancePalette

    def initialize(request:)
      @request = request
    end

    def view_template
      turbo_frame_tag 'modal' do
        div(class: 'fixed inset-0 z-50 flex flex-col justify-end lg:items-center lg:justify-center bg-slate-900/40',
            data:  backdrop_data) do
          div(class: 'relative bg-slate-50 rounded-t-3xl px-5 pt-3 pb-8 shadow-2xl lg:rounded-2xl lg:w-[460px] lg:p-0') do
            handle
            render_header
            render_form
          end
        end
      end
    end

    private

    def maintenance = @request.maintenance

    def status_key = Vehicles::MaintenanceStatus.for(maintenance.progress)

    def status_style = MAINTENANCE_STATUS_STYLES.fetch(status_key)

    def delimited(value) = helpers.number_with_delimiter(value, delimiter: '.')

    def backdrop_data
      {
        controller:                                 'modal mark-done-km',
        action:                                     'mousedown->modal#handleBackgroundClick',
        mark_done_km_odometer_value:                maintenance.vehicle.odometer_km,
        mark_done_km_max_value:                     maintenance.max_done_km,
        mark_done_km_last_km_value:                 maintenance.last_done_km,
        mark_done_km_item_value:                    t("vehicle.maintenances.catalog.#{maintenance.category}"),
        mark_done_km_below_message_value:           t('maintenances.mark_done.errors.below_last', km: '__KM__'),
        mark_done_km_below_companion_message_value: t('maintenances.mark_done.errors.below_last_companion', item: '__ITEM__', km: '__KM__'),
        mark_done_km_above_message_value:           t('maintenances.mark_done.errors.above_max', km: '__KM__'),
        mark_done_km_advance_message_value:         t('maintenances.mark_done.odometer_advance', km: '__KM__')
      }
    end

    def handle
      div(class: 'w-10 h-1 rounded-full bg-slate-300 mx-auto mb-4 lg:hidden')
    end

    def render_header
      div(class: 'flex items-start gap-3 mb-5 lg:mb-0 lg:items-center lg:justify-between lg:px-6 lg:pt-5 lg:pb-4 lg:border-b lg:border-slate-200') do
        status_icon
        header_text
        close_button
      end
    end

    def status_icon
      div(class: 'w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 lg:hidden',
          style: "background: #{status_style[:color]}20; color: #{status_style[:color]};") do
        render maintenance_icon(maintenance.category).new(class: 'w-[18px] h-[18px]')
      end
    end

    def header_text
      div(class: 'min-w-0') do
        h2(class: 'text-lg font-bold text-slate-900') { title }
        p(class: 'text-xs text-slate-500 mt-0.5') { subtitle }
      end
    end

    def title
      t('maintenances.mark_done.title', item: t("vehicle.maintenances.catalog.#{maintenance.category}"))
    end

    def subtitle
      t('maintenances.mark_done.subtitle', last: delimited(maintenance.last_done_km), interval: delimited(maintenance.interval_km))
    end

    def close_button
      button(type: 'button', data: { action: 'modal#close' },
             class: 'hidden lg:flex w-8 h-8 rounded-full items-center justify-center text-slate-400') do
        render PhlexIcons::Lucide::X.new(class: 'w-[18px] h-[18px]')
      end
    end

    def render_form
      form_with(model: @request, scope: :mark_done, url: helpers.maintenance_mark_done_path(maintenance), method: :patch,
                class: 'space-y-4 lg:space-y-5 lg:px-6 lg:py-5') do |form|
        km_field(form)
        done_on_field(form)
        companions_block(form) if maintenance.companions.any?
        footer
      end
    end

    def km_field(form)
      div do
        label(class: 'text-xs font-semibold text-slate-600') { t('maintenances.mark_done.labels.done_km') }
        div(class: km_box_classes, data: { controller: 'integer-field' }) do
          input(type: 'text', inputmode: 'numeric', autocomplete: 'off',
                value:      delimited(@request.done_km),
                aria_label: t('maintenances.mark_done.labels.done_km'),
                class:      'flex-1 text-base font-semibold text-slate-800 tabular-nums border-0 p-0 bg-transparent focus:outline-none focus:ring-0',
                data:       { integer_field_target: 'display', action: 'input->integer-field#format' })
          render form.hidden_field(:done_km, data: { integer_field_target: 'input' })
          span(class: 'text-sm text-slate-400') { 'km' }
        end
        km_error
        km_info
        km_help
      end
    end

    def km_box_classes
      base = 'mt-1.5 flex items-center rounded-xl border bg-white px-3.5 h-12 focus-within:border-blue-500 focus-within:ring-2 focus-within:ring-blue-100'
      km_error_message.present? ? "#{base} border-red-400 ring-2 ring-red-100" : "#{base} border-slate-200"
    end

    def km_error_message
      @request.errors[:done_km].first
    end

    def km_error
      p(class: "text-xs text-red-600 mt-1.5 flex items-start gap-1 #{'hidden' if km_error_message.blank?}",
        data:  { mark_done_km_target: 'error' }) do
        render PhlexIcons::Lucide::TriangleAlert.new(class: 'w-[13px] h-[13px] mt-px flex-shrink-0')
        plain km_error_message
      end
    end

    def done_km_ahead_of_odometer?
      @request.done_km.present? && @request.done_km > maintenance.vehicle.odometer_km
    end

    def km_info
      p(class: "text-xs text-blue-700 mt-1.5 flex items-start gap-1 #{'hidden' unless km_error_message.blank? && done_km_ahead_of_odometer?}",
        data:  { mark_done_km_target: 'info' }) do
        render PhlexIcons::Lucide::Gauge.new(class: 'w-[13px] h-[13px] mt-px flex-shrink-0')
        plain t('maintenances.mark_done.odometer_advance', km: delimited(@request.done_km || maintenance.vehicle.odometer_km))
      end
    end

    def km_help
      p(class: "text-xs text-slate-500 mt-1.5 #{'hidden' unless km_error_message.blank? && !done_km_ahead_of_odometer?}",
        data:  { mark_done_km_target: 'help' }) { t('maintenances.mark_done.help') }
    end

    def done_on_field(form)
      div do
        label(class: 'text-xs font-semibold text-slate-600') { t('maintenances.mark_done.labels.done_on') }
        div(class: 'mt-1.5 flex items-center rounded-xl border border-slate-200 bg-white px-3.5 h-12') do
          render form.date_field(:done_on, class: 'flex-1 text-base font-semibold text-slate-800 border-0 p-0 bg-transparent focus:outline-none focus:ring-0')
        end
      end
    end

    def companions_block(form)
      div do
        p(class: 'text-xs font-semibold text-slate-600') { t('maintenances.mark_done.labels.companions') }
        div(class: 'mt-1 divide-y divide-slate-100 rounded-xl border border-slate-200 bg-white px-3.5') do
          render form.hidden_field(:companion_ids, value: '', multiple: true)
          maintenance.companions.each { |companion| companion_row(companion) }
        end
        p(class: 'text-[11px] text-slate-500 mt-1.5') { t('maintenances.mark_done.companions_hint') }
      end
    end

    def companion_row(companion)
      companion_status_key = Vehicles::MaintenanceStatus.for(companion.progress)
      style = MAINTENANCE_STATUS_STYLES.fetch(companion_status_key)

      div(class: 'flex items-center gap-3 py-2.5') do
        input(type: 'checkbox', name: 'mark_done[companion_ids][]', value: companion.id,
              checked: @request.companion_ids.include?(companion.id),
              class:   'w-5 h-5 rounded-md accent-blue-600',
              data:    { last_km: companion.last_done_km, item: t("vehicle.maintenances.catalog.#{companion.category}"),
                         mark_done_km_target: 'companion', action: 'change->mark-done-km#refresh' })
        span(class: 'flex-1 text-sm text-slate-700') { t("vehicle.maintenances.catalog.#{companion.category}") }
        span(class: "text-[10px] font-bold uppercase tracking-wide rounded-full px-2 py-0.5 border #{style[:badge_class]}") do
          t("vehicle.maintenances.status.#{companion_status_key}")
        end
      end
    end

    def footer
      div(class: 'grid grid-cols-[auto_1fr] gap-2 mt-6 lg:flex lg:justify-end lg:mt-0 lg:px-6 lg:py-4 lg:border-t lg:border-slate-200') do
        button(type: 'button', data: { action: 'modal#close' },
               class: 'px-4 h-12 rounded-xl border border-slate-200 bg-white text-sm font-semibold text-slate-600 lg:h-10 lg:rounded-lg') do
          t('maintenances.mark_done.buttons.cancel')
        end
        button(type: 'submit', disabled: km_error_message.present?,
               class: 'h-12 rounded-xl text-sm font-semibold text-white bg-blue-600 disabled:bg-blue-300 lg:h-10 lg:rounded-lg',
               data:  { mark_done_km_target: 'submit', turbo_submits_with: t('maintenances.mark_done.buttons.saving') }) do
          t('maintenances.mark_done.buttons.save')
        end
      end
    end
  end
end
