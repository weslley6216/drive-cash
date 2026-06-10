module Vehicles
  class OdometerHeroComponent < ApplicationComponent
    def initialize(current_km:, km_this_month:, variant: :mobile)
      @current_km = current_km
      @km_this_month = km_this_month
      @variant = variant
    end

    def view_template
      div(class: container_classes) do
        div(class: 'flex items-start justify-between') do
          div do
            p(class: 'text-xs font-medium text-slate-400 uppercase tracking-wider') { t('vehicle.odometer.label') }
            p(class: km_classes, style: 'font-feature-settings: "tnum"') do
              plain helpers.number_with_delimiter(@current_km, delimiter: '.')
              span(class: 'text-base font-medium text-slate-400 ml-1') { t('vehicle.odometer.unit') }
            end
          end
          button(class: 'text-xs bg-white/10 border border-white/20 rounded-full px-3 py-1.5 text-white',
                 type: 'button',
                 data: { controller: 'odometer-edit', action: 'click->odometer-edit#open' }) do
            t('vehicle.odometer.update')
          end
        end
        delta_row
      end
    end

    private

    def container_classes
      base = 'rounded-2xl p-5 bg-gradient-to-br from-slate-800 to-slate-900 text-white'
      @variant == :desktop ? "#{base} lg:p-7" : base
    end

    def km_classes
      base = 'text-3xl font-bold mt-1 tracking-tight'
      @variant == :desktop ? "#{base} lg:text-5xl" : base
    end

    def delta_row
      div(class: 'flex items-center gap-2 mt-3') do
        render PhlexIcons::Lucide::TrendingUp.new(class: 'w-3.5 h-3.5 text-emerald-400', 'stroke-width': '2.5')
        formatted = helpers.number_with_delimiter(@km_this_month, delimiter: '.')
        span(class: 'text-sm text-slate-300') { t('vehicle.odometer.delta_this_month', value: formatted) }
      end
    end
  end
end
