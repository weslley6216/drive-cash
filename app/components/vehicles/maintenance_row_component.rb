module Vehicles
  class MaintenanceRowComponent < ApplicationComponent
    include MaintenancePalette

    def initialize(row:)
      @maintenance = row.maintenance
      @progress = row.progress
      @km_until = row.km_until
      @target = row.target
      @status_key = row.status_key
      @style = MAINTENANCE_STATUS_STYLES.fetch(@status_key)
    end

    def view_template
      div(id: dom_id(@maintenance), class: card_classes) do
        div(class: 'flex items-center gap-3 p-3 pb-2') do
          icon_block
          info_block
          edit_link
        end
        progress_bar
        action_slot
      end
    end

    private

    def card_classes
      base = 'bg-white rounded-xl shadow-sm border border-slate-100'
      @style[:tint_class].empty? ? base : "#{base} #{@style[:tint_class]}"
    end

    def icon_block
      div(class: 'w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0',
          style: "background: #{@style[:color]}20; color: #{@style[:color]};") do
        render maintenance_icon(@maintenance.category).new(class: 'w-[18px] h-[18px]')
      end
    end

    def info_block
      div(class: 'flex-1 min-w-0') do
        div(class: 'flex items-center gap-2') do
          p(class: 'text-sm font-semibold text-slate-800 truncate') { t("vehicle.maintenances.catalog.#{@maintenance.category}") }
          span(class: "text-[10px] font-bold uppercase tracking-wide rounded-full px-2 py-0.5 border flex-shrink-0 #{@style[:badge_class]}") do
            t("vehicle.maintenances.status.#{@status_key}")
          end
        end
        p(class: 'text-xs text-slate-500 mt-0.5') { meta_line }
      end
    end

    def meta_line
      if @km_until >= 0
        plain "#{t('vehicle.maintenances.km_remaining')} "
        span(class: 'font-semibold text-slate-600') { t('vehicle.maintenances.km_value', value: helpers.number_with_delimiter(@km_until, delimiter: '.')) }
        plain " · #{t('vehicle.maintenances.at_km', value: helpers.number_with_delimiter(@target, delimiter: '.'))}"
      else
        span(class: 'font-semibold text-red-600') do
          t('vehicle.maintenances.overdue', value: helpers.number_with_delimiter(@km_until.abs, delimiter: '.'))
        end
      end
    end

    def edit_link
      link_to(helpers.edit_maintenance_path(@maintenance),
              aria_label: t('vehicle.maintenances.edit'),
              class:      'w-9 h-9 rounded-full flex items-center justify-center text-slate-400 flex-shrink-0',
              data:       { turbo_frame: 'modal' }) do
        render PhlexIcons::Lucide::Pencil.new(class: 'w-[16px] h-[16px]')
      end
    end

    def progress_bar
      fill = [[4, @progress].max, 100].min
      div(class: 'h-1.5 bg-slate-100 mx-3 rounded-full overflow-hidden') do
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
  end
end
