module Vehicles
  class MaintenanceCardComponent < ApplicationComponent
    CATEGORY_STYLES = {
      'oil_change' => { color: '#3b82f6', icon: PhlexIcons::Lucide::Wrench },
      'brake'      => { color: '#10b981', icon: PhlexIcons::Lucide::Shield },
      'alignment'  => { color: '#f59e0b', icon: PhlexIcons::Lucide::Gauge },
      'tires'      => { color: '#64748b', icon: PhlexIcons::Lucide::Circle },
      'other'      => { color: '#64748b', icon: PhlexIcons::Lucide::Wrench }
    }.freeze

    def initialize(maintenance:, km_until:, days_until:, urgent:, progress_pct:, variant: :mobile)
      @maintenance = maintenance
      @km_until = km_until
      @days_until = days_until
      @urgent = urgent
      @progress_pct = progress_pct
      @variant = variant
    end

    def view_template
      div(class: card_classes) do
        div(class: 'flex items-center gap-3 p-3') do
          icon_block
          info_block
          urgent_badge if @urgent
          mark_done_button if @variant == :desktop
        end
        progress_bar
      end
    end

    private

    def card_classes
      base = 'bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden'
      @urgent ? "#{base} border-amber-200 bg-amber-50/40" : base
    end

    def icon_block
      style = CATEGORY_STYLES.fetch(@maintenance.category, CATEGORY_STYLES['other'])
      div(class: 'w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0',
          style: "background: #{style[:color]}20; color: #{style[:color]};") do
        render style[:icon].new(class: 'w-4 h-4')
      end
    end

    def info_block
      div(class: 'flex-1 min-w-0') do
        p(class: 'text-sm font-semibold text-slate-800') { @maintenance.name }
        p(class: 'text-xs text-slate-500 mt-0.5') { meta_line }
      end
    end

    def meta_line
      parts = []
      parts << t('vehicle.maintenances.km_remaining', value: @km_until) if @km_until
      parts << t('vehicle.maintenances.days_remaining', value: @days_until) if @days_until
      parts.join(' · ')
    end

    def urgent_badge
      span(class: 'text-[10px] font-bold uppercase text-amber-700 bg-amber-100 border border-amber-200 rounded-full px-2 py-1 whitespace-nowrap') do
        t('vehicle.maintenances.urgent')
      end
    end

    def mark_done_button
      style = CATEGORY_STYLES.fetch(@maintenance.category, CATEGORY_STYLES['other'])
      button(class: 'text-xs font-medium px-3 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 text-slate-700',
             style: "color: #{style[:color]};",
             type: 'button',
             data: { controller: 'maintenance-mark', maintenance_id: @maintenance.id }) do
        t('vehicle.maintenances.mark_done')
      end
    end

    def progress_bar
      style = CATEGORY_STYLES.fetch(@maintenance.category, CATEGORY_STYLES['other'])
      div(class: 'h-1 bg-slate-100 mx-3 mb-3 rounded-full overflow-hidden') do
        div(class: 'h-full rounded-full',
            style: "width: #{@progress_pct}%; background: #{style[:color]};")
      end
    end
  end
end
