module Vehicles
  class OdometerHeroComponent < ApplicationComponent
    FRESH_THRESHOLD_DAYS = 7

    def initialize(current_km:, km_this_month:, updated_days_ago: nil, variant: :mobile)
      @current_km = current_km
      @km_this_month = km_this_month
      @updated_days_ago = updated_days_ago
      @variant = variant
    end

    def view_template
      div(class: container_classes) do
        odometer_block
        update_button if @variant == :mobile
        caption
      end
    end

    private

    def stale?
      @updated_days_ago.nil? || @updated_days_ago > FRESH_THRESHOLD_DAYS
    end

    def container_classes
      base = 'rounded-2xl bg-gradient-to-br from-slate-800 to-slate-900 text-white p-5'
      base += ' lg:p-7 flex flex-col justify-between' if @variant == :desktop
      base += ' ring-2 ring-amber-400/60' if stale?
      base
    end

    def odometer_block
      div do
        p(class: 'text-[11px] font-semibold text-slate-400 uppercase tracking-wider') { t('vehicle.odometer.label') }
        p(class: km_classes, style: 'font-feature-settings: "tnum"') do
          plain helpers.number_with_delimiter(@current_km, delimiter: '.')
          span(class: 'text-base font-medium text-slate-400 ml-1.5') { t('vehicle.odometer.unit') }
        end
        div(class: 'flex items-center gap-2 mt-2 flex-wrap') do
          freshness_pill
          span(class: 'text-xs text-slate-400') do
            t('vehicle.odometer.delta_month', value: helpers.number_with_delimiter(@km_this_month, delimiter: '.'))
          end
        end
      end
    end

    def km_classes
      base = 'text-4xl font-bold mt-1 tracking-tight'
      @variant == :desktop ? "#{base} lg:text-5xl" : base
    end

    def freshness_pill
      if stale?
        span(class: 'inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold text-amber-300 bg-amber-400/15 border border-amber-400/30') do
          span(class: 'relative flex h-1.5 w-1.5') do
            span(class: 'animate-ping absolute inline-flex h-full w-full rounded-full bg-amber-400 opacity-75')
            span(class: 'relative inline-flex rounded-full h-1.5 w-1.5 bg-amber-400')
          end
          plain freshness_text
        end
      else
        span(class: 'inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-medium text-slate-300 bg-white/10 border border-white/15') do
          span(class: 'inline-flex rounded-full h-1.5 w-1.5 bg-emerald-400')
          plain freshness_text
        end
      end
    end

    def freshness_text
      return t('vehicle.odometer.stale_unknown') if @updated_days_ago.nil?
      return t('vehicle.odometer.stale', count: @updated_days_ago) if stale?

      t('vehicle.odometer.fresh', count: @updated_days_ago)
    end

    def update_button
      link_to(helpers.edit_vehicle_path, class: button_classes, data: { turbo_frame: 'modal' }) do
        render PhlexIcons::Lucide::Camera.new(class: 'w-[18px] h-[18px]')
        plain t('vehicle.odometer.update')
      end
    end

    def button_classes
      base = 'mt-4 w-full flex items-center justify-center gap-2 rounded-xl py-3 text-sm font-semibold transition'
      tone = stale? ? 'bg-amber-400 text-slate-900 hover:bg-amber-300' : 'bg-white text-slate-900 hover:bg-slate-100'
      "#{base} #{tone}"
    end

    def caption
      p(class: caption_classes) do
        render PhlexIcons::Lucide::Camera.new(class: 'w-3.5 h-3.5') if @variant == :desktop
        plain t('vehicle.odometer.photo_hint')
        span(class: 'text-slate-500') { " · #{t('vehicle.odometer.soon')}" }
      end
    end

    def caption_classes
      if @variant == :desktop
        'text-xs text-slate-400 mt-3 flex items-center gap-1.5'
      else
        'text-[11px] text-slate-400 text-center mt-2'
      end
    end
  end
end
