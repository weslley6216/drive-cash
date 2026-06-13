module Vehicles
  class MaintenanceRowComponent < ApplicationComponent
    def initialize(maintenance:, progress:, km_until:, target:, status_key:, variant: :mobile)
      @maintenance = maintenance
      @progress = progress
      @km_until = km_until
      @target = target
      @variant = variant
      @status = Vehicles::MaintenanceStatus.for(progress)
    end

    def view_template
      div(class: card_classes) do
        div(class: 'flex items-center gap-3 p-3') do
          icon_block
          info_block
          mark_done_button if @variant == :desktop
        end
        progress_bar
      end
    end

    private

    def card_classes
      base = 'bg-white rounded-2xl border border-slate-100 overflow-hidden'
      @status.tint_class.empty? ? base : "#{base} #{@status.tint_class}"
    end

    def icon_block
      div(class: 'w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0',
          style: "background: #{@status.color}20; color: #{@status.color};") do
        render @maintenance.icon_component.new(class: 'w-[18px] h-[18px]')
      end
    end

    def info_block
      div(class: 'flex-1 min-w-0') do
        div(class: 'flex items-center gap-2') do
          p(class: 'text-sm font-semibold text-slate-800 truncate') { t("vehicle.maintenances.catalog.#{@maintenance.category}") }
          span(class: "text-[10px] font-bold uppercase tracking-wide rounded-full px-2 py-0.5 border flex-shrink-0 #{@status.badge_class}") do
            t("vehicle.maintenances.status.#{@status.key}")
          end
        end
        p(class: 'text-xs text-slate-500 mt-0.5') { meta_line }
      end
    end

    def meta_line
      if @km_until >= 0
        plain t('vehicle.maintenances.km_remaining', value: helpers.number_with_delimiter(@km_until, delimiter: '.'))
        plain ' · '
        plain t('vehicle.maintenances.at_km', value: helpers.number_with_delimiter(@target, delimiter: '.'))
      else
        span(class: 'font-semibold text-red-600') do
          t('vehicle.maintenances.overdue', value: helpers.number_with_delimiter(@km_until.abs, delimiter: '.'))
        end
      end
      span(class: 'text-slate-400') { " · #{t('vehicle.maintenances.est_cost', value: format_currency(@maintenance.estimated_cost || 0))}" }
    end

    def mark_done_button
      link_to(t('vehicle.maintenances.mark_done'), helpers.mark_done_maintenance_path(@maintenance),
              class: 'text-xs font-medium text-slate-600 border border-slate-200 rounded-lg px-3 py-1.5 hover:bg-slate-50 flex-shrink-0',
              data: { turbo_method: :patch })
    end

    def progress_bar
      fill = [[4, @progress].max, 100].min
      div(class: 'h-1.5 bg-slate-100 mx-3 mb-3 rounded-full overflow-hidden') do
        div(class: 'h-full rounded-full', style: "width: #{fill}%; background: #{@status.color};")
      end
    end
  end
end
