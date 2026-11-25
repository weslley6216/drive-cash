module Vehicles
  class InsightCardComponent < ApplicationComponent
    def initialize(insight:, variant: :mobile)
      @insight = insight
      @variant = variant
    end

    def view_template
      div(class: container_classes) do
        icon_block
        div(class: 'flex-1 min-w-0') do
          p(class: 'text-sm font-semibold text-blue-900') { title }
          p(class: body_classes) { body }
        end
        analysis_link if desktop?
      end
    end

    private

    def desktop?
      @variant == :desktop
    end

    def container_classes
      base = 'bg-blue-50 border border-blue-200 flex items-start gap-3'
      desktop? ? "rounded-xl #{base} p-5 gap-4" : "rounded-2xl #{base} p-4"
    end

    def icon_block
      size = desktop? ? 'w-11 h-11' : 'w-9 h-9'
      div(class: "#{size} rounded-full bg-blue-400/30 flex items-center justify-center flex-shrink-0") do
        render PhlexIcons::Lucide::Zap.new(class: "#{desktop? ? 'w-5 h-5' : 'w-[18px] h-[18px]'} text-blue-700")
      end
    end

    def body_classes
      desktop? ? 'text-sm text-blue-800 mt-1 leading-relaxed' : 'text-xs text-blue-800 mt-0.5 leading-relaxed'
    end

    def analysis_link
      link_to(t('vehicle.insight.see_analysis'), helpers.analysis_path,
              class: 'text-xs font-medium text-blue-900 hover:underline flex-shrink-0')
    end

    def title
      t('vehicle.insight.cheapest.title', vendor: @insight[:winner])
    end

    def body
      t("vehicle.insight.cheapest.#{desktop? ? 'body_desktop' : 'body'}",
        kml:          format_kml(@insight[:winner_kml]),
        other:        format_kml(@insight[:runner_up_kml]),
        other_vendor: @insight[:runner_up],
        vendor:       @insight[:winner],
        savings:      format_currency_short(@insight[:savings]))
    end

    def format_kml(value)
      number_with_precision(value, precision: 1, separator: ',', delimiter: '.')
    end
  end
end
