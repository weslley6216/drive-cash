module Vehicles
  class MaintenanceRowComponent < ApplicationComponent
    include MaintenancePalette

    def initialize(row:, variant: :mobile)
      @maintenance = row.maintenance
      @progress = row.progress
      @km_until = row.km_until
      @target = row.target
      @status_key = row.status_key
      @style = MAINTENANCE_STATUS_STYLES.fetch(@status_key)
      @variant = variant
    end

    def view_template
      desktop? ? desktop_row : mobile_row
    end

    private

    def desktop?
      @variant == :desktop
    end

    def mobile_row
      div(id: dom_id(@maintenance), class: card_classes) do
        div(class: 'flex items-center gap-3 p-3 pb-2') do
          icon_block
          info_block
          edit_link
        end
        progress_bar('h-1.5 bg-slate-100 mx-3 rounded-full overflow-hidden')
        action_slot
      end
    end

    def desktop_row
      div(id: dom_id(@maintenance), class: desktop_row_classes) do
        link_to(helpers.edit_maintenance_path(@maintenance),
                class: 'flex items-center gap-4 flex-1 min-w-0',
                aria:  { label: t('vehicle.maintenances.edit') },
                data:  { turbo_frame: 'modal' }) do
          icon_block
          info_block
        end
        desktop_mark_done_link
      end
    end

    def card_classes
      base = 'bg-white rounded-xl shadow-sm border border-slate-100'
      @style[:tint_class].empty? ? base : "#{base} #{@style[:tint_class]}"
    end

    def desktop_row_classes
      base = 'flex items-center gap-4 px-5 py-4 hover:bg-slate-50'
      @style[:tint_class].empty? ? base : "#{base} #{@style[:tint_class]}"
    end

    def icon_block
      size = desktop? ? 'w-11 h-11' : 'w-10 h-10'
      icon_size = desktop? ? 'w-5 h-5' : 'w-[18px] h-[18px]'
      div(class: "#{size} rounded-xl flex items-center justify-center flex-shrink-0",
          style: "background: #{@style[:color]}20; color: #{@style[:color]};") do
        render maintenance_icon(@maintenance.category).new(class: icon_size)
      end
    end

    def info_block
      div(class: 'flex-1 min-w-0') do
        div(class: 'flex items-center gap-2') do
          p(class: name_classes) { t("vehicle.maintenances.catalog.#{@maintenance.category}") }
          span(class: "text-[10px] font-bold uppercase tracking-wide rounded-full px-2 py-0.5 border flex-shrink-0 #{@style[:badge_class]}") do
            t("vehicle.maintenances.status.#{@status_key}")
          end
        end
        p(class: 'text-xs text-slate-500 mt-0.5') { meta_line }
        progress_bar('h-1.5 bg-slate-100 rounded-full overflow-hidden mt-2 max-w-md') if desktop?
      end
    end

    def name_classes
      desktop? ? 'text-sm font-semibold text-slate-900' : 'text-sm font-semibold text-slate-800 truncate'
    end

    def meta_line
      if @km_until >= 0
        plain "#{t('vehicle.maintenances.km_remaining')} "
        span(class: 'font-semibold text-slate-600') { t('vehicle.maintenances.km_value', value: helpers.number_with_delimiter(@km_until, delimiter: '.')) }
        plain " · #{t('vehicle.maintenances.at_km', value: helpers.number_with_delimiter(@target, delimiter: '.'))}"
      else
        span(class: 'font-semibold text-red-600') do
          plain t('vehicle.maintenances.overdue', value: helpers.number_with_delimiter(@km_until.abs, delimiter: '.'))
          plain " · #{t('vehicle.maintenances.at_km', value: helpers.number_with_delimiter(@target, delimiter: '.'))}" if desktop?
        end
      end
      estimated_cost_meta
    end

    def estimated_cost_meta
      return if @maintenance.estimated_cost.blank?

      key = desktop? ? 'vehicle.maintenances.estimated_cost_desktop' : 'vehicle.maintenances.estimated_cost'
      span(class: 'text-slate-400') { " #{t(key, amount: format_currency(@maintenance.estimated_cost))}" }
    end

    def edit_link
      link_to(helpers.edit_maintenance_path(@maintenance),
              aria:  { label: t('vehicle.maintenances.edit') },
              class: 'w-9 h-9 rounded-full flex items-center justify-center text-slate-400 flex-shrink-0',
              data:  { turbo_frame: 'modal' }) do
        render PhlexIcons::Lucide::Pencil.new(class: 'w-[16px] h-[16px]')
      end
    end

    def progress_bar(track_classes)
      fill = [[4, @progress].max, 100].min
      div(class: track_classes) do
        div(class: 'h-full rounded-full', style: "width: #{fill}%; background: #{@style[:color]};")
      end
    end

    def action_slot
      return div(class: 'h-3') if @status_key == :ok

      div(class: 'p-3 pt-2.5') { mark_done_link }
    end

    def mark_done_link
      link_to(helpers.new_maintenance_mark_done_path(@maintenance),
              class: 'w-full inline-flex items-center justify-center gap-1.5 rounded-lg bg-white border border-slate-200 py-2 text-xs font-semibold text-slate-700 shadow-sm',
              data:  { turbo_frame: 'modal' }) do
        render PhlexIcons::Lucide::Check.new(class: 'w-[14px] h-[14px]')
        plain " #{t('vehicle.maintenances.mark_done')}"
      end
    end

    def desktop_mark_done_link
      link_to(helpers.new_maintenance_mark_done_path(@maintenance),
              class: 'text-xs font-medium text-slate-600 border border-slate-200 rounded-lg px-3 py-1.5 hover:bg-slate-50 flex-shrink-0',
              data:  { turbo_frame: 'modal' }) { t('vehicle.maintenances.mark_done_desktop') }
    end
  end
end
