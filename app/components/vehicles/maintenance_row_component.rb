module Vehicles
  class MaintenanceRowComponent < ApplicationComponent
    include MaintenancePalette

    STATUS_STYLES = {
      overdue: { color: '#dc2626', badge_class: 'text-red-700 bg-red-100 border-red-200', tint_class: 'border-red-200 bg-red-50/60' },
      soon:    { color: '#f59e0b', badge_class: 'text-amber-700 bg-amber-100 border-amber-200', tint_class: 'border-amber-200 bg-amber-50/50' },
      ok:      { color: '#10b981', badge_class: 'text-slate-500 bg-slate-100 border-slate-200', tint_class: '' }
    }.freeze

    def initialize(row:, variant: :mobile)
      @maintenance = row.maintenance
      @progress = row.progress
      @km_until = row.km_until
      @target = row.target
      @status_key = row.status_key
      @variant = variant
      @style = STATUS_STYLES.fetch(@status_key)
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
              data:  { turbo_method: :patch })
    end

    def progress_bar
      fill = [[4, @progress].max, 100].min
      div(class: 'h-1.5 bg-slate-100 mx-3 mb-3 rounded-full overflow-hidden') do
        div(class: 'h-full rounded-full', style: "width: #{fill}%; background: #{@style[:color]};")
      end
    end
  end
end
